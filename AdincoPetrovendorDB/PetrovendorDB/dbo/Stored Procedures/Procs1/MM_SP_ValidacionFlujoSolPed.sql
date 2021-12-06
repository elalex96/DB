USE [Petrovendor]
GO
/****** Object:  StoredProcedure [dbo].[MM_SP_ValidacionFlujoSolPed]    Script Date: 26/11/2021 01:56:01 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Jose Roman>
-- Create date: <03-01-2018>
-- Description:	<Se valida si ya existe un flujo de aprobacion para la solped>
-- =============================================

ALTER PROCEDURE [dbo].[MM_SP_ValidacionFlujoSolPed]	
	@IdSolicitudPedido INT,
	/*---------------------Parametros contrato---------------------*/
	@IdContrato INT = NULL,
	@IdUsuario INT = NULL,
	@FechaRegistro DATETIME = NULL	
	/*---------------------Parametros contrato---------------------*/
AS
BEGIN
	SELECT COUNT(IdOperacion)
	FROM dbo.TA_Operacion o (NOLOCK)
	WHERE IdDocumento = @IdSolicitudPedido
	AND o.IdTipoOperacion= 2
END
