import { create } from 'zustand'

const useBearStore = create((set) => ({
  worldIdProof: {},
  setWorldIdProof: (proof: any) => set(() => ({ worldIdProof: proof })),
}))

export default useBearStore;