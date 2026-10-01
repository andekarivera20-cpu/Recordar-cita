# RecordaCita

Sistema de recordatorios de citas para pequeños negocios.

## Web pública
https://andekarivera20-cpu.github.io/Recordar-cita/

## Archivos principales
- `index.html` — página comercial y formulario de interesados.
- `recordatorios-citas.html` — demo interactiva del sistema de citas.
- `admin.html` — panel privado para gestionar interesados.
- `supabase/schema.sql` — esquema documentado del backend de Supabase, sin secretos.

## Funcionalidad actual
- Demo sin registro.
- Alta, edición, filtrado y eliminación de citas.
- Simulación de recordatorios en la demo.
- Worker real de WhatsApp en Supabase Edge Functions, programado cada minuto.
- Formulario comercial para captar interesados.
- Mini CRM privado con estados: Nuevo, Contactado, Cliente y Descartado.
- Datos almacenados en Supabase con RLS.
- Precio mostrado actualmente: 99 € de puesta en marcha + 9,90 €/mes.

## Importante
Las credenciales privadas, tokens y contraseñas no se guardan en GitHub.

El envío automático por WhatsApp ya está preparado en el backend. Para que un negocio envíe mensajes reales necesita conectar su cuenta de WhatsApp Business de Meta, indicar el Phone Number ID, guardar un Access Token válido y tener aprobada la plantilla `appointment_reminder` con 4 variables: cliente, fecha, hora y negocio.
