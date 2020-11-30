-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
create PROCEDURE SP_DatosGeneralesExternos
@IdProveedor INT,
@Tipo NVARCHAR(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	IF (@Tipo = 'IMAGEN_EMPRESA')
	BEGIN
	DECLARE @IMAGEN INT 
	SET @IMAGEN = (SELECT COUNT (IdImagen) FROM S_ImagenPerfil WHERE IdProveedor = @IdProveedor AND IsVisible = 1)
	IF (@IMAGEN > 0)
	BEGIN
	SELECT 'REGISTRADO'
	END
	END

	IF (@Tipo = 'DIAS_CREDITO')
	BEGIN
	DECLARE @DIAS INT 
	SET @DIAS = (SELECT COUNT (CP.IdCondicionPago) FROM PV_CondicionesPago CP 
			   INNER JOIN PV_ContratistaSubContratista CSC
			   ON CP.IdContratistaSubContratista = CSC.IdRelacion 
			   WHERE CSC.IdContratista = @IdProveedor AND CP.DiasCredito != 0)
	IF (@DIAS > 0)
	BEGIN
	SELECT 'REGISTRADO'
	END 
	END


END
