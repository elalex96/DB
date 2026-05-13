-- =============================================  
-- Author:   Daniel AC  
-- Create date: 14/10/2020  
-- Description:   Se agrego consulta para saber si la nota de credito ya se encuentra en adinco 
-- =============================================  
CREATE PROCEDURE [dbo].[SP_NC_ConsultarInformacionNotaCredito]
    @IdProveedor INT,
    @IdUsuario INT,
    @IdNotaCredito INT
AS
BEGIN
	/*CONSULTA PARA OBTENER INFORMACIÓN BASICA DE LA NOTA DE CREDITO*/
    DECLARE @IdUsuarioAdinco INT;
    DECLARE @IdContrato INT;
    DECLARE @IdFacturaAdinco INT;

	/*OBTENER USUARIO ADINCO*/
    SELECT @IdUsuarioAdinco = U.IdUsuarioADINCO
    FROM dbo.S_Usuario U
        LEFT JOIN dbo.S_UsuarioProveedor UP
            ON U.IdUsuario=UP.IdUsuario 
    WHERE U.IdUsuario = @IdUsuario
          AND UP.IdProveedor = @IdProveedor;

	/*OBTENER ID DE LA NOTA DE CREDITO SI YA SE ENCUENTRA EN ADINCO*/
    SELECT @IdFacturaAdinco = FIA.IdFactura
    FROM dbo.MM_AceptacionNotaCredito NC
        JOIN dbo.FI_Factura FI
            ON NC.IdFacturaNotaCredito = FI.IdFactura
               AND NC.IdAceptacionNotaCredito = @IdNotaCredito
        JOIN Adinco..FI_Factura FIA
            ON FI.UUID = FIA.UUID COLLATE SQL_Latin1_General_CP1_CI_AS;



    SELECT F.IdContrato,               --0
           @IdUsuarioAdinco,           --1
           F.ComprobantePDFByte,       --2
           F.ComprobanteXMLByte,       --3
           NC.TipoRelacion,            --4
           NC.CFDIRelacionados,        --5
           F.IdFactura,                --6
           F.UUID,                     --7
           ISNULL(@IdFacturaAdinco, 0) --8
    FROM dbo.MM_AceptacionNotaCredito NC
        INNER JOIN dbo.FI_Factura F
            ON F.IdFactura = NC.IdFacturaNotaCredito
        INNER JOIN dbo.MM_AceptacionPedido AP
            ON AP.IdAceptacionPedido = NC.IdAceptacionPedido
        INNER JOIN dbo.MM_Pedido P
            ON P.IdPedido = AP.IdPedido
    WHERE NC.IdAceptacionNotaCredito = @IdNotaCredito;


END;


