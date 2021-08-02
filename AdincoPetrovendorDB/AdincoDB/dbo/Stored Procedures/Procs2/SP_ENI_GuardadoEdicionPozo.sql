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
	@FechaConfirmacion DATETIME,
	@PozoDesc BIT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @POZO nvarchar(1000) = (SELECT NombreInstalacion FROM dbo.CO_Instalacion where IdInstalacion = @IdInstalacion);
	DECLARE @POZOalt nvarchar(1000) = (SELECT NombreInstalacionAlterno FROM dbo.CO_Instalacion where IdInstalacion = @IdInstalacion);
	DECLARE @POZOID INT = (SELECT TOP 1 WelIID FROM dbo.CO_Instalacion where IdInstalacion = @IdInstalacion);


	UPDATE PR_Pozo
	SET Estatus = @Estado,
		FechaConfirmacionDescubrimiento = @FechaConfirmacion,
		Modificado = GETDATE(),
		ModificadoPor = @IdUsuario,
		ConfirmacionDescubrimiento = @PozoDesc
	WHERE Id = @POZOID;

	UPDATE CO_Instalacion
	SET IdEstatus = @Estado
	WHERE IdInstalacion = @IdInstalacion;

	SELECT 'SUCCES'
END
