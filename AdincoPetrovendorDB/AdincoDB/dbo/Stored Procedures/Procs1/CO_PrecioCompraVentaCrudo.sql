create PROCEDURE [dbo].[CO_PrecioCompraVentaCrudo]
@IdUsuario INT,
@mes INT,
@año INT

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
	,'J' AS 'Anexo2'
	,'CC Palomas' AS 'Punto de Medición2'
	,'2018' AS 'Mes'
	,'5678'AS 'PrecioVenta'
	, '5,005,0' AS 'Volumen (bls)2' 
	,'679' AS 'Tarifa PEP2'
	,'123' AS 'Tarifa PL2'
	,'12.22' AS 'Tarifa TRI2'
	,'0.15' AS 'Margen Comercial2'
	,'213' AS 'Precio de Compra2'
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
            CONVERT(sql_variant, [VolumenBls]) as [Volumen (Bls)],
			CONVERT(sql_variant, [PrecioVenta]) as [Precio de Venta],
            CONVERT(sql_variant, [TarifaPep]) as [Tarifa PEP],
			CONVERT(sql_variant, [TarifaPL]) as [Tarifa PL],
			CONVERT(sql_variant, [TarifaTRI]) as [Tarifa TRI],
			CONVERT(sql_variant, [MargenC]) as [Margen Comercial],
			CONVERT(sql_variant, [PrecioCom]) as [Precio de Compra]
        FROM
            #compraVentaCrudo
    ) as t
UNPIVOT(FieldValue for FieldName in ([Área Contractual],[Anexo],[Mes],[Volumen (Bls)],[Precio de Venta],[Tarifa PEP],[Tarifa PL],[Tarifa TRI],[Margen Comercial],[Precio de Compra])) as unpvt

END