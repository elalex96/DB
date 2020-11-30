-- =============================================
-- Author:		<Jose Roman>
-- Create date: <01-04-2018>
-- Description:	<Insert para los documentos de soporte en Recepcion de factura en petrovendor>
-- Update date: <10-05-2018> SE AGREGO PARAMETROS DETALLE DEL DOCUMENTO s3
-- =============================================

CREATE PROCEDURE [dbo].[MM_MPY_SP_AgregarDocSoporteRecepcionFactura]
	@IdAceptacionPedido INT,
	@Documento NVARCHAR(max),
	@NombreDoc varchar(150),
	/*NUEVOS PARAMETROS*/
	@Carpeta NVARCHAR(max),
	@Identificador NVARCHAR(max),
	@Extension NVARCHAR(max),
	@Mime NVARCHAR(MAX),
	/*--------------------parametros contrato  --------------------*/
    @IdContrato    INT = null,
    @IdUsuario     INT = null,
    @FechaRegistro DATETIME = null
	/*-------------------------------------------------------------*/
AS
BEGIN
	INSERT INTO dbo.MPY_MM_DocSoporteRecepcionFactura
	(
	    IdAceptacionPedido,
	    Documento,
	    NombreDoc,
	    CargadoPor,
	    CargadoEl,
	    Eliminado,
		Comentario,
		Carpeta,
		Identificador,
		Extension,
		Mime
	)
	VALUES
	(   @IdAceptacionPedido,                     -- IdAceptacionPedido - int
	    @Documento,                   -- Documento - nvarchar(max)
	    @NombreDoc,                    -- NombreDoc - varchar(150)
	    @IdUsuario,                     -- CargadoPor - int
	    GETDATE(), -- CargadoEl - smalldatetime
	    0, -- Eliminado - bit
		'',
	    @Carpeta,
		@Identificador,
		@Extension,
		@Mime
	)
END