use Petrovendor
go
drop proc if exists USP_SEL_DG_TipoDomicilio
go
-- ============================================= 
-- Create: DANIEL AC 
-- Updated date: 07/05/2026 
-- Description: CONSULTA DE TIPOS DE DOMICILIO 
-- Comentario: Se agregan los nombres de usuario creador y modificador para mostrar auditoria en la pantalla.
-- =============================================
CREATE PROCEDURE [dbo].[USP_SEL_DG_TipoDomicilio]
    @IdContrato INT = NULL,
    @IdUsuario INT = NULL,
    @FechaRegistro DATETIME = NULL
AS
BEGIN
    SELECT d.IdTipoDomicilio,
           d.TipoDomicilio,
           d.Activo,
           uc.Nombre AS CreadoPor,
           d.CreadoEl,
           um.Nombre AS ModificadoPor,
           d.EditadoEl AS ModificadoEl
    FROM dbo.DG_TipoDomicilio d
    LEFT JOIN dbo.S_Usuario uc ON uc.IdUsuario = d.CreadoPor
    LEFT JOIN dbo.S_Usuario um ON um.IdUsuario = d.EditadorPor
END
