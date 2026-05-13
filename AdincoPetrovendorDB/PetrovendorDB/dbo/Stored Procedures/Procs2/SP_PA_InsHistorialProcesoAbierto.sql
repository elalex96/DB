-- =============================================
-- Author:		<Abel Rivera>
-- Create date: <20/01/2020>
-- Description:	<Guarda el historial de cambio de un proceso abierto>
-- =============================================
CREATE PROCEDURE SP_PA_InsHistorialProcesoAbierto
@IdProveedor INT,
@IdUsuario INT,
@IdTabla INT,
@IdHistorialTipo INT,
@IdOperacion INT,
@Descripcion NVARCHAR(MAX)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @NVersion INT
	IF @IdHistorialTipo = 1 -- cotizacion vencida
	BEGIN
		SET @NVersion = ( SELECT COUNT(1) FROM dbo.PA_HistorialProcesoAbierto WHERE IdTabla = @IdTabla AND IdProveedor = @IdProveedor )
		IF( @NVersion > 0 )
			SET @NVersion = @NVersion + 1; -- incrementamos en num version
		ELSE 
			SET @NVersion = 1
	END


	INSERT INTO dbo.PA_HistorialProcesoAbierto
	(
	    IdUsuario,
	    IdProveedor,
	    IdOperacion,
	    FechaRegistro,
	    Descripcion,
		IdTabla,
		HistorialTipo,
		Version
	)
	VALUES
	(   @IdUsuario,         -- IdUsuario - int
	    @IdProveedor,         -- IdProveedor - int
	    @IdOperacion,         -- IdOperacion - int
	    GETDATE(), -- FechaRegistro - datetime
	    @Descripcion,        -- Descripcion - nvarchar(max)
		@IdTabla,
		@IdHistorialTipo,
		@NVersion
	)

	SELECT SCOPE_IDENTITY();

END
