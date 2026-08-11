<script setup lang="ts">
// The actual footer markup/logic lives in @bonhamlab/slidev-template's
// FooterBar.vue (see that package's CLAUDE.md for the z-50/useSlideContext
// gotchas). This wrapper only exists to hand it this talk's footer-info.ts —
// it can't live inside the package itself, since the package has no way to
// read a per-talk file.
import { footerInfo } from './footer-info'
</script>

<template>
  <FooterBar :footer-info="footerInfo" />
</template>
