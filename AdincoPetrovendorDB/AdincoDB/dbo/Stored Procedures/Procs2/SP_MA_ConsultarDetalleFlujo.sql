-- =============================================
-- Author:		DANIEL AC
-- Create date: 24-01-18
-- Description:	Insertar información del flujo de aprobación 
-- =============================================
CREATE PROCEDURE [dbo].[SP_MA_ConsultarDetalleFlujo]
-- Add the parameters for the stored procedure here
@Idoperacion INT,
@IdContrato	INT=0,
@IdUsuario  INT = 0,
@IdSubcontratista INT =0,
@FechaRegistro DATETIME= '25-01-2017 00:00'
AS
BEGIN
    SET NOCOUNT ON;
	
			SELECT F.IdFlujo,F.Nombre,F.IdTipoOperacion,F.Descripcion,F.IdTipoFlujo, TF.TipoFlujo, TOF.Nombre
			FROM dbo.MA_Flujo AS F
			INNER JOIN dbo.MA_Operacion AS O ON O.IdOperacion=F.IdFlujo
			INNER JOIN dbo.MA_TipoFlujo AS TF ON TF.IdTipoFlujo=F.IdTipoFlujo
			INNER JOIN dbo.MA_TipoOperacion AS TOF ON TOF.IdTipoOperacion=F.IdTipoOperacion
			WHERE O.IdOperacion=@Idoperacion
END;

