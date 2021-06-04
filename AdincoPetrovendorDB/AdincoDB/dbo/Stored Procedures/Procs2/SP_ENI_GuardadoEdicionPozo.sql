USE [Adinco]
GO
/****** Object:  StoredProcedure [dbo].[SP_ENI_GuardadoEdicionPozo]    Script Date: 04/06/2021 01:33:25 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<ALEXANDER GOMEZ>
-- Create date: <02-06-2021>
-- Description:	<GUARDADO DE LA EDICION DE POZO>
-- =============================================
CREATE PROCEDURE [dbo].[SP_ENI_GuardadoEdicionPozo]
	-- Add the parameters for the stored procedure here
	@IdContrato INT, 
	@IdUsuario  INT,
	@IdInstalacion INT,
	@Estado INT,
	@FechaConfirmacion DATETIME
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @POZO nvarchar(1000) = (SELECT NombreInstalacion FROM dbo.CO_Instalacion where IdInstalacion = @IdInstalacion);
	DECLARE @POZOalt nvarchar(1000) = (SELECT NombreInstalacionAlterno FROM dbo.CO_Instalacion where IdInstalacion = @IdInstalacion);
	DECLARE @POZOID INT = (SELECT TOP 1 WelIID FROM dbo.CO_Instalacion where IdInstalacion = 10490);


	UPDATE PR_Pozo
	SET Estatus = @Estado,
		FechaConfirmacionDescubrimiento = @FechaConfirmacion,
		Modificado = GETDATE(),
		ModificadoPor = @IdUsuario
	WHERE Id = @POZOID;

	SELECT 'SUCCES'

END