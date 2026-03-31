<template>
  <router-view />
</template>

<script setup>
</script>

<style>
:root {
  --cm-primary:   #0ea5e9;
  --cm-success:   #10b981;
  --cm-warning:   #f59e0b;
  --cm-danger:    #ef4444;
  --cm-bg:        #f9fafb;
  --cm-radius-md: 12px;
  --cm-radius-lg: 20px;
  --cm-shadow-sm: 0 1px 3px rgba(0,0,0,.06);
  --cm-shadow-md: 0 6px 20px rgba(0,0,0,.10);
}

* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

body {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
  background-color: var(--cm-bg);
  color: #333;
}
</style>
