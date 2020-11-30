
-- =============================================
-- Author:		<Jose Roman>
-- Create date: <09-01-2019>
-- Description:	<Se guarda o actualiza las restricciones configuradas por un proveedor>
-- =============================================

CREATE PROCEDURE FI_SP_GuardarRestriccionFactura	
	@IdProveedor INT,
	@Activo BIT,
	@Monto MONEY,
	/*---------------------Parametros contrato---------------------*/
	@IdContrato INT = NULL,
	@IdUsuario INT = NULL,
	@FechaRegistro DATETIME = NULL	
	/*---------------------Parametros contrato---------------------*/
AS
BEGIN
	DECLARE @Existe INT,
		@IdRestriccion INT

	SET @Existe = (SELECT COUNT(IdRestriccion) FROM dbo.FI_RestriccionFactura WHERE IdProveedor = @IdProveedor)

	IF(@Existe > 0)
	BEGIN
	    UPDATE dbo.FI_RestriccionFactura
		SET Activo = @Activo,
			Excedente = @Monto,
			ModificadoPor = @IdUsuario,
			ModificadoEl = GETDATE()
		WHERE IdProveedor = @IdProveedor	
	END
	ELSE
	BEGIN
	    INSERT INTO dbo.FI_RestriccionFactura
	    (
	        IdProveedor,
	        Excedente,
	        Activo,
	        ModificadoPor,
	        ModificadoEl
	    )
	    VALUES
	    (   @IdProveedor,        -- IdProveedor - int
	        @Monto,     -- Excedente - money
	        @Activo,     -- Activo - bit
	        @IdUsuario,        -- ModificadoPor - int
	        GETDATE() -- ModificadoEl - datetime
	    )
	END

	SELECT ISNULL(IdRestriccion, 0) FROM dbo.FI_RestriccionFactura WHERE IdProveedor = @IdProveedor
END