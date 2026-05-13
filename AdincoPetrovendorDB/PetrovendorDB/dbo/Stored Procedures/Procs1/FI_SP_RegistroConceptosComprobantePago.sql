
-- =============================================
-- Author:		<Jose Roman>
-- Create date: <12-06-2018>
-- Description:	<Se registra un concepto de un comprobante de pago>
-- Create date: <07-02-2018>
-- Description:	<Se agrega el envio del comprobante a Adinco>
-- =============================================
-- =============================================
-- Author:   Daniel AC
-- Create date: 01/10/2019
-- Description:   Se removio insertado de registros de Adinco 
-- =============================================

CREATE procedure [dbo].[FI_SP_RegistroConceptosComprobantePago]
	@IdFactura INT,
	@Descripcion VARCHAR(max),
	@Cantidad FLOAT,
	@Unidad NVARCHAR(max),
	@ValorUnitario MONEY,
	@Importe MONEY,
	@NoIdentificiacion NVARCHAR(max),
	/*--------------------parametros contrato  --------------------*/
    @IdContrato    INT = null,
    @IdUsuario     INT = null,
    @FechaRegistro DATETIME = null
	/*-------------------------------------------------------------*/
AS
BEGIN


	--Registro en petrovendor
	INSERT INTO dbo.FI_CFDIConcepto
	(
	    IdFactura,
	    Descripcion,
	    Cantidad,
	    Unidad,
	    ValorUnitario,
	    Importe,
	    NoIdentificacion,
	    CreadoPor
	)
	VALUES
	(   @IdFactura,
		@Descripcion,
		@Cantidad,
		@Unidad,
		@ValorUnitario,
		@Importe,
		@NoIdentificiacion,
		@IdUsuario
	)

END

