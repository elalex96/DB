
CREATE PROCEDURE [dbo].[DEA_SP_AdministrarSolicitudCNProveedorExtranjero]
@TipoConsulta NVARCHAR(MAX),
@ContratoId INT = 0,
@ProveedorId INT = 0
AS
BEGIN

	DECLARE @Contador INT = 0

	IF @TipoConsulta ='AGREGAR'
	BEGIN 
		
		SELECT @Contador=COUNT(1) 
		FROM DEA_SolicitudCNProveedorExtranjero 
		WHERE IdContrato = @ContratoId
		AND IdProveedor = @ProveedorId
			
		IF @Contador>0
		BEGIN 
			/*ACTIVAR PROVEEDOR*/
			UPDATE DEA_SolicitudCNProveedorExtranjero
			SET Activo= 1,
			ModificadoEl = GETDATE()
			WHERE IdContrato = @ContratoId
			AND IdProveedor = @ProveedorId			
		END 
		ELSE 
		BEGIN
			/*AGREGAR PROVEEDOR*/
			INSERT INTO DEA_SolicitudCNProveedorExtranjero(IdProveedor, IdContrato,CreadoEl,Activo)
			VALUES(@ProveedorId,@ContratoId,GETDATE(),1)
		END 
	END 

	IF @TipoConsulta ='ELIMINAR'
	BEGIN 

		/*DESACTIVAR PROVEEDOR*/
		UPDATE DEA_SolicitudCNProveedorExtranjero
		SET Activo= 0,
		ModificadoEl = GETDATE()
		WHERE IdContrato = @ContratoId
		AND IdProveedor = @ProveedorId

	END 
			
END
