-- =============================================
-- Modificacion:<Jose Roman>
-- Create date: <27-03-2018>
-- Description:	<Se agregan parametros de contrato, la moneda y filtro de contrato>
-- =============================================
-- Modificacion:		Jose Roman
-- Create date: 15-08-2018
-- Description:	Se filtran las aprobaciones de tipo serial, donde los aprobadores con numero de secuencia menos aun no han aprobado la operacion			
-- =============================================
-- Modificacion:		Alexander Gomez
-- Create date: 30-01-2019
-- Description:	Se filtran las aprobaciones por proveedor	
-- =============================================
CREATE PROCEDURE [dbo].[sp_compraspendientes] 
	@IdUsuario INT, 
	@IdProveedor INT,
	/*--------------------parametros contrato  --------------------*/
    @IdContrato    INT = null,
    --@IdUsuario     INT = null,
    @FechaRegistro DATETIME = null
	/*-------------------------------------------------------------*/
AS
BEGIN
	
	--DECLARE @FlujoSerial TABLE(IdOperacion INT)

	--INSERT INTO @FlujoSerial
	--(
	--    IdOperacion
	--)
	--SELECT IdOperacion 
	--FROM dbo.FN_FlujoSerialNoAprobados (@IdUsuario, @IdProveedor, 14)

	SELECT  reg.IdRegistro,
			O.IdOperacion AS Operacion,
			O.Descripcion AS Descripcion,
			O.IdDocumento AS Compra,
			O.IdAsignador AS creado,
			S_Usuario.IdUsuario AS num_user,
			1 AS tpuser,
			DATEADD(DAY, vigencia.DiaVencimiento, O.FechaRegistro) AS Finalizacion,
			PG.IdPedido AS IdPedidoGeneral,
			fac.Emisor,
			fac.FechaTimbrado,
			((fac.MontoConIva * 100)/100) AS Monto,
			instalacion.NombreInstalacion AS Instalacion,
			fac.Moneda
	FROM S_Usuario      
		LEFT JOIN dbo.TA_Tarea TA
				ON TA.IdAprobador = dbo.S_Usuario.IdUsuario
		LEFT JOIN TA_Operacion O
				ON O.IdOperacion = TA.IdOperacion 
		LEFT JOIN dbo.TA_Vencimiento vigencia
				ON vigencia.IdVencimiento = O.IdVigencia
		LEFT JOIN dbo.MM_Pedidos PG
				ON PG.IdIdentificador = O.IdDocumento AND PG.IdTipoPedido = 1 AND PG.IdProveedorCliente = O.IdProveedor
		LEFT JOIN dbo.FI_Factura fac
				ON fac.IdFactura = O.IdDocumento      
		LEFT JOIN dbo.CO_Registro reg
				ON reg.IdFactura = fac.IdFactura
		LEFT JOIN Adinco.dbo.CO_Instalacion instalacion
				ON instalacion.IdInstalacion = reg.IdInstalacion
		LEFT JOIN dbo.S_UsuarioProveedor UP
				ON UP.IdUsuario = dbo.S_Usuario.IdUsuario
		--LEFT JOIN @FlujoSerial fs 
				--ON fs.IdOperacion = O.IdOperacion AND fs.IdOperacion IS NULL -- Se excluyen los flujos de tipo serial que no han sido aprobados por aprobadores superiores
	WHERE O.IdEstatusOperacion = 1
		AND O.IdTipoOperacion = 14
		AND S_Usuario.IdUsuario = @IdUsuario 
		AND UP.IdProveedor = @IdProveedor
		AND fac.IdContrato = UP.idContrato
		AND O.IdOperacion NOT IN (SELECT IdOperacion FROM dbo.FN_FlujoSerialNoAprobados(@IdUsuario,@IdProveedor,14))
AND TA.idestatus = 1 -->No mostrar si ya se aprobo MG 
	ORDER BY O.IdOperacion DESC;
END;