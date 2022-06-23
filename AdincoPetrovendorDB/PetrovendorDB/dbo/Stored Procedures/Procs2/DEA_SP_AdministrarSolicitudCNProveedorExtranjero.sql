USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'DEA_SP_AdministrarSolicitudCNProveedorExtranjero'
)
    DROP PROCEDURE DEA_SP_AdministrarSolicitudCNProveedorExtranjero;
	GO
/****** Object:  StoredProcedure [dbo].[SRAP_ConsultarSolicitudesAceptacionPedido]    Script Date: 08/06/2022 03:15:13 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

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
