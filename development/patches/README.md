# CI Patch Series

These patches preserve the four commits added on top of owner baseline:

```text
16065f0cc7b382a6257d5347d62f9fa7a36ea5f4
```

Apply them in numeric order with:

```bash
git am /home/skeler/exynos2100-kernel-project/patches/000*.patch
```

They culminate in the KernelSU Next-only workflow at:

```text
629ae7243bdabb79f8aea3c6d5e391a74bdb1f5b
```

The live fork already contains these commits; the patch files are a recovery/export copy.
