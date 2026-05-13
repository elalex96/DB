use Petrovendor
go
drop proc if exists AD_SP_ConsultaImagenesPredeterminadas
go
-- ============================================= 
-- Create: DANIEL AC 
-- Updated date: 07/05/2026 
-- Description: CONSULTA DE IMAGENES PREDETERMINADAS 
-- Comentario: Se agregan los nombres de usuario creador y modificador para mostrar auditoria en la pantalla.
-- =============================================
CREATE PROCEDURE [dbo].[AD_SP_ConsultaImagenesPredeterminadas]  
(
   
    @IdContrato    INT,
    @IdUsuario     INT,
    @FechaRegistro DATETIME
)
AS
BEGIN
    SELECT ip.IdImagenPredeterminada,
           ip.Detalle,
           ip.Imagen,
           ip.ImagenThumb,
           uc.Nombre AS CreadoPor,
           ip.FechaAlta AS CreadoEl,
           um.Nombre AS ModificadoPor,
           ip.EditadaEl AS ModificadoEl
    FROM dbo.PV_ImagenPredeterminada ip
    LEFT JOIN dbo.S_Usuario uc ON uc.IdUsuario = ip.CreadoPor
    LEFT JOIN dbo.S_Usuario um ON um.IdUsuario = ip.EditadaPor
END


