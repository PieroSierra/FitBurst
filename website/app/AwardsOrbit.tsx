"use client";

import { useEffect, useRef } from "react";
import * as THREE from "three";
import { GLTFLoader } from "three/addons/loaders/GLTFLoader.js";
import { RoomEnvironment } from "three/addons/environments/RoomEnvironment.js";

/* The app's own award models, converted from Reality Composer USDZ to GLB.
 * The star cup spins in the middle; the rest orbit it on a tilted ring and
 * pop in one by one as the section scrolls into view. `rot` stands a model
 * upright where its source file lies flat. */
type Award = { file: string; rot?: [number, number, number] };

const CENTRE: Award = { file: "star-cup.glb" };

const RING: Award[] = [
  { file: "coin-zap-gold.glb" },
  { file: "diamond-blue.glb" },
  { file: "coin-star-gold.glb" },
  { file: "gem-red.glb" },
  { file: "coin-zap-silver.glb" },
  { file: "diamond-green.glb" },
  { file: "coin-heart-gold.glb" },
  { file: "gem-blue.glb" },
  { file: "coin-crown-silver.glb" },
  { file: "diamond-red.glb" },
];

const RING_RADIUS = 3.1;
const RING_SPEED = 0.12; // radians per second
const SPIN_SPEED = 0.9; // radians per second, each award on its own axis

// Scroll progress (0 → 1) at which the first and last ring awards pop in.
const POP_START = 0.12;
const POP_END = 0.62;
const POP_LENGTH = 0.14;

const clamp01 = (v: number) => (v < 0 ? 0 : v > 1 ? 1 : v);

// Overshoots past 1 and settles, so each award lands with a small bounce.
function easeOutBack(t: number) {
  const c1 = 1.9;
  const c3 = c1 + 1;
  return 1 + c3 * Math.pow(t - 1, 3) + c1 * Math.pow(t - 1, 2);
}

/** Centres a loaded model on the origin and scales its largest side to `size`. */
function normalise(model: THREE.Object3D, size: number, rot?: [number, number, number]) {
  if (rot) model.rotation.set(rot[0], rot[1], rot[2]);
  model.updateMatrixWorld(true);
  const box = new THREE.Box3().setFromObject(model);
  const dims = box.getSize(new THREE.Vector3());
  const centre = box.getCenter(new THREE.Vector3());
  const wrap = new THREE.Group();
  model.position.sub(centre);
  wrap.add(model);
  wrap.scale.setScalar(size / Math.max(dims.x, dims.y, dims.z));
  return wrap;
}

export default function AwardsOrbit() {
  const hostRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const host = hostRef.current;
    if (!host) return;

    const reduced = window.matchMedia("(prefers-reduced-motion: reduce)").matches;

    const renderer = new THREE.WebGLRenderer({ antialias: true, alpha: true });
    renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
    renderer.toneMapping = THREE.ACESFilmicToneMapping;
    renderer.toneMappingExposure = 1.1;
    renderer.outputColorSpace = THREE.SRGBColorSpace;
    host.appendChild(renderer.domElement);

    const scene = new THREE.Scene();
    const pmrem = new THREE.PMREMGenerator(renderer);
    const envTexture = pmrem.fromScene(new RoomEnvironment(), 0.04).texture;
    scene.environment = envTexture;

    // A lime rim light from behind, matching the app's award glow.
    const rim = new THREE.PointLight(0xa4fa53, 40, 20);
    rim.position.set(0, 1.5, -3);
    scene.add(rim);
    scene.add(new THREE.AmbientLight(0xffffff, 0.4));

    const camera = new THREE.PerspectiveCamera(32, 1, 0.1, 100);
    camera.position.set(0, 2.3, 10.5);
    camera.lookAt(0, 0, 0);

    const ring = new THREE.Group();
    ring.rotation.x = 0.08;
    scene.add(ring);

    const centreSlot = new THREE.Group();
    scene.add(centreSlot);

    const ringSlots = RING.map((_, i) => {
      const slot = new THREE.Group();
      const a = (i / RING.length) * Math.PI * 2;
      slot.position.set(Math.sin(a) * RING_RADIUS, 0, Math.cos(a) * RING_RADIUS);
      slot.scale.setScalar(0);
      // Stagger each award's spin so they do not turn in lockstep.
      slot.rotation.y = i * 1.3;
      ring.add(slot);
      return slot;
    });
    centreSlot.scale.setScalar(0);

    const loader = new GLTFLoader();
    let disposed = false;
    const load = (award: Award, slot: THREE.Group, size: number) =>
      loader.loadAsync(`/awards/${award.file}`).then((gltf) => {
        if (disposed) return;
        slot.add(normalise(gltf.scene, size, award.rot));
      });

    // --- scroll progress, same measure as ScrollReveal ---
    let progress = reduced ? 1 : 0;
    const measureProgress = () => {
      if (reduced) return;
      const r = host.getBoundingClientRect();
      const vh = window.innerHeight || document.documentElement.clientHeight;
      progress = clamp01((vh - r.top) / r.height);
    };

    // --- pointer tilt ---
    let tiltX = 0;
    let tiltY = 0;
    const onPointer = (e: PointerEvent) => {
      const r = host.getBoundingClientRect();
      tiltY = ((e.clientX - r.left) / r.width - 0.5) * 0.5;
      tiltX = ((e.clientY - r.top) / r.height - 0.5) * 0.2;
    };

    const resize = () => {
      const w = host.clientWidth;
      const h = host.clientHeight;
      renderer.setSize(w, h, false);
      camera.aspect = w / h;
      // Back the camera off just far enough that the ring's width fits the
      // canvas: half the ring plus an award, over the horizontal half-FOV.
      const halfFov = Math.tan(THREE.MathUtils.degToRad(camera.fov / 2)) * camera.aspect;
      camera.position.z = Math.max(10.5, (RING_RADIUS + 1.2) / halfFov);
      camera.updateProjectionMatrix();
    };

    const clock = new THREE.Clock();
    let elapsed = 0;
    const frame = () => {
      const dt = Math.min(clock.getDelta(), 0.1);
      if (!reduced) elapsed += dt;

      const centrePop = easeOutBack(clamp01((progress - POP_START + 0.06) / POP_LENGTH));
      centreSlot.scale.setScalar(centrePop * 1.15);
      centreSlot.rotation.y = elapsed * SPIN_SPEED * 0.5;

      ringSlots.forEach((slot, i) => {
        const start = POP_START + (i / (RING.length - 1)) * (POP_END - POP_START);
        const t = clamp01((progress - start) / POP_LENGTH);
        slot.scale.setScalar(t === 0 ? 0 : easeOutBack(t));
        slot.rotation.y = i * 1.3 + elapsed * SPIN_SPEED;
      });

      // Scrolling adds a quarter turn on top of the slow drift.
      ring.rotation.y = elapsed * RING_SPEED + progress * Math.PI * 0.5;
      scene.rotation.x += (tiltX - scene.rotation.x) * 0.06;
      scene.rotation.y += (tiltY - scene.rotation.y) * 0.06;

      renderer.render(scene, camera);
    };

    let visible = false;
    const setLoop = () => renderer.setAnimationLoop(visible ? frame : null);
    const io = new IntersectionObserver(([entry]) => {
      visible = entry.isIntersecting;
      clock.getDelta();
      setLoop();
    });
    io.observe(host);

    const onScroll = () => measureProgress();
    window.addEventListener("scroll", onScroll, { passive: true });
    host.addEventListener("pointermove", onPointer);
    const ro = new ResizeObserver(() => {
      resize();
      frame();
    });
    ro.observe(host);

    resize();
    measureProgress();
    Promise.all([
      load(CENTRE, centreSlot, 1.9),
      ...RING.map((a, i) => load(a, ringSlots[i], 1.05)),
    ])
      .then(() => {
        if (!disposed) frame();
      })
      .catch(() => {});

    return () => {
      disposed = true;
      renderer.setAnimationLoop(null);
      io.disconnect();
      ro.disconnect();
      window.removeEventListener("scroll", onScroll);
      host.removeEventListener("pointermove", onPointer);
      scene.traverse((o) => {
        if (o instanceof THREE.Mesh) {
          o.geometry.dispose();
          const mats = Array.isArray(o.material) ? o.material : [o.material];
          for (const m of mats) {
            for (const v of Object.values(m)) if (v instanceof THREE.Texture) v.dispose();
            m.dispose();
          }
        }
      });
      envTexture.dispose();
      pmrem.dispose();
      renderer.dispose();
      renderer.domElement.remove();
    };
  }, []);

  return <div ref={hostRef} className="fb-orbit" aria-hidden="true" />;
}
