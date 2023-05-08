create PROCEDURE [dbo].[CO_PrecioCompraVentaGas]
@IdUsuario INT ,
@Mes INT,
@Año Int
AS
BEGIN

-------------------------------------------------------
 CREATE TABLE #compraVentaCrudo
  (
  Area VARCHAR(100),
  Anexo VARCHAR(50),
  Mes  VARCHAR(50),
  PrecioVenta VARCHAR(50),
  PuntoMedicion VARCHAR(50),
  VolumenBls VARCHAR(50),
  TarifaPep VARCHAR(50),
  TarifaPL VARCHAR(50),
  TarifaTRI VARCHAR(50),
  MargenC VARCHAR(50),
  PrecioCom VARCHAR(50),
  )
------------------------------------------------------
INSERT INTO #compraVentaCrudo	 (
Area ,
 Anexo ,
  PuntoMedicion ,
  Mes,
  VolumenBls,
  PrecioVenta,
  TarifaPep ,
  TarifaPL ,
  TarifaTRI ,
  MargenC 
  ,PrecioCom )
  SELECT    
	DISTINCT    
	CO_AreaContractual.NombreAreaContractual
	,'JJ' AS 'Anexo2'
	,'CC Palmas' AS 'Punto de Medición2'
	,'Mayo-2019' AS 'Mes'
	,'56'AS 'PrecioVenta'
	, '5005,0' AS 'Volumen (bls)2' 
	,'67.0988' AS 'Tarifa PEP2'
	,'345678' AS 'Tarifa PL2'
	,'23.2' AS 'Tarifa TRI2'
	,'3.987' AS 'Margen Comercial2'
	,'21.213' AS 'Precio de Compra2'
	FROM AP_PerfilUsuario AS PU INNER JOIN
                         AP_Usuario ON PU.UsuarioID = AP_Usuario.UsuarioID INNER JOIN
                         AP_Perfil ON PU.PerfilID = AP_Perfil.IdPerfil INNER JOIN
                         AP_Rol ON AP_Perfil.IdRol = AP_Rol.IdRol INNER JOIN
                         CO_Contrato ON AP_Perfil.IdContrato = CO_Contrato.IdContrato INNER JOIN
                         CO_AreaContractual ON CO_Contrato.IdAreaContractual = CO_AreaContractual.IdAreaContractual
						 WHERE (@IdUsuario = PU.UsuarioID)
-------------------------------------------------------
SELECT
     FieldName,FieldValue
FROM
    (
        SELECT
            CONVERT(sql_variant, [Area]) as [Área Contractual],
            CONVERT(sql_variant, [Anexo]) as [Anexo],
			CONVERT(sql_variant, [Mes]) as [Mes],
            CONVERT(sql_variant, [VolumenBls]) as [Volumen (MMPC)],
			CONVERT(sql_variant, [PrecioVenta]) as [Precio de Venta],
            CONVERT(sql_variant, [TarifaPep]) as [Tarifa PEP],
			CONVERT(sql_variant, [TarifaPL]) as [Tarifa PL],
			CONVERT(sql_variant, [TarifaTRI]) as [Tarifa TRI],
			CONVERT(sql_variant, [MargenC]) as [Margen Comercial],
			CONVERT(sql_variant, [PrecioCom]) as [Precio de Compra (USD/MPC)]
        FROM
            #compraVentaCrudo
    ) as t
UNPIVOT(FieldValue for FieldName in ([Área Contractual],[Anexo],[Mes],[Volumen (MMPC)],[Precio de Venta],[Tarifa PEP],[Tarifa PL],[Tarifa TRI],[Margen Comercial],[Precio de Compra (USD/MPC)])) as unpvt

	--SELECT ' as ' AS FieldName, 'hola' AS FieldValue 
END