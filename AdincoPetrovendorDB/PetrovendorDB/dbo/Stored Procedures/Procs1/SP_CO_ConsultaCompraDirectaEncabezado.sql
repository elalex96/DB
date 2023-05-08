
-- =============================================
-- Author:   Daniel AC
-- Create date: 26-09-2019
-- Description: Agregue cambio de referecias al s3 en los documentos adjuntos y columnas referentes al Error SAT
-- =============================================
-- Author:   Alexander Gomez
-- Create date: 04/06/2020
-- Description: se agrego la cuenta bancaria en la consulta
-- =============================================
-- Author:   Alexander Gomez
-- Create date: 06/11/2020
-- Description: se agrego los dias de credito en la consulta
-- =============================================

CREATE  PROCEDURE [dbo].[SP_CO_ConsultaCompraDirectaEncabezado] --0,13148,0,206171
	@IdUsuario INT, @IdRegistro INT, @IdFactura INT , @IdLineaPresupuesto INT,
	/*--------------------parametros contrato  --------------------*/
	@IdContrato INT = NULL ,
	--@IdUsuario     INT = null,
	@FechaRegistro DATETIME = NULL
	/*-------------------------------------------------------------*/
AS
	BEGIN
		DECLARE @RazonSocial NVARCHAR (MAX)
		--DECLARE @IdContrato int 
		DECLARE @IdPeriodo INT
		DECLARE @IdPresupuesto INT

		IF ( @IdFactura = 0 )
			BEGIN
				SET @RazonSocial = (   SELECT	TOP 1
												p.RazonSocial + ' ' + ISNULL ( p.RegimenCapital, '' )
										 FROM	S_Proveedor p
												INNER JOIN dbo.FI_Factura f
														   ON f.Emisor = p.RFC
												INNER JOIN dbo.CO_Registro r
														   ON r.IdFactura = f.IdFactura
										WHERE	r.IdRegistro = @IdRegistro ) ;

				SET LANGUAGE Spanish ;

				SELECT	linea.IdPresupuesto, coRegistro.IdLineaPresupuestoMes, '' AS ArchivoXML, fiFactura.NombreXML ,
						NULL AS PDF ,	--es de tipo varbinary
						'' ArchivoPDF , -- es byte array
						fiFactura.SubTotal, linea.IdActvidadHidrocarburo, coRegistro.CuentaContable ,
						coRegistro.CentroCostos, coRegistro.MontoRegistro, coRegistro.InicioEjecucion ,
						coRegistro.FinEjecucion, coRegistro.IdInstalacion, coRegistro.Comentarios, fiFactura.IdFactura ,
						centroCosto.CentroCosto, cuentaSh.Descripcion, cuentaContable.Descripcion ,
						instalacion.NombreInstalacion, prove.RazonSocial, CASE WHEN @RazonSocial = '' THEN
																				   fiFactura.Emisor
																			  WHEN @RazonSocial IS NULL THEN
																				  fiFactura.Emisor
																			  ELSE
																				  @RazonSocial
																		  END AS ProveedorEmisor, 0 AS Pedido ,
						ISNULL ( PC.NombrePeriodo, 'No Disponible' ) AS Periodo ,
						ISNULL (( presupuesto.Nombre + ' [' + presupuesto.IdPresupuestoCNH + ']' ), 'No Disponible' ) AS Presupuesto ,
						ISNULL (
							( RIGHT('00' + CAST(MONTH ( linea.AC_PRESUP_MES ) AS VARCHAR (2)), 2) + ' '
							  + DATENAME ( MONTH, linea.AC_PRESUP_MES ) + ' '
							  + CAST(YEAR ( linea.AC_PRESUP_MES ) AS VARCHAR (50)) + ' - '
							  + CASE
									WHEN P.CIEP = 1
									THEN TSC.NombreTipoServicio
									ELSE ACTP.DescripcionActividadPetrolera
								END + '('
							  + CASE
									WHEN P.CIEP = 1
									THEN SACI.NombreSubactividad
									ELSE SACP.SubactividadPetrolera
								END + ')' ), 'No Disponible' ) AS Mes_Presupuestado ,
						ISNULL ( fiFactura.MontoConIva, 0 ) AS Total ,
						( ISNULL ( fiFactura.MontoConIva, 0 ) - ISNULL ( fiFactura.SubTotal, 0 )) AS IVA ,
						PG.IdPedido AS IdPedidoGeneral, fiFactura.Moneda,
						ISNULL(fiFactura.IdLectorXMLSAT,1) AS IdLectorXMLSAT,
						REPLACE(ISNULL(fiFactura.ErroSAT,''),'Error SAT:','') AS ErrorSAT,
						ISNULL(ISAT.DireccionWeb,'') AS DireccionWeb,
						ISNULL(fiFactura.UUID,'') AS UUID,
						ISNULL(fiFactura.Emisor,'') AS RFC_Emisor,
						ISNULL(fiFactura.Receptor,'') AS RFC_Receptor,
						ISNULL(PG.CuentaBancaria,'') AS CuentaBancaria,
						ISNULL(PG.DiasCredito,'') AS DiasCredito
				  FROM	dbo.CO_Registro AS coRegistro
						LEFT JOIN dbo.FI_Factura AS fiFactura
								   ON fiFactura.IdFactura = coRegistro.IdFactura
						LEFT JOIN dbo.CC_CentroCosto centroCosto
								   ON centroCosto.IdCentroCosto = coRegistro.CentroCostos
						LEFT JOIN dbo.DG_CuentaContable cuentaContable
								   ON cuentaContable.Id = coRegistro.CuentaContable
						LEFT JOIN Adinco.dbo.CO_LineaPresupuestoMes linea
								   ON linea.IdLineaPresupuestoMes = coRegistro.IdLineaPresupuestoMes
						--------------------------------------------------------------------------------------------------
						--------------------------------------------------------------------------------------------------
						LEFT JOIN Adinco.dbo.CO_Presupuesto P ON P.idPresupuesto = linea.IdPresupuesto
						LEFT JOIN Adinco.dbo.CO_ProgramaActividad PA ON PA.IdProgramaActividad = P.idProgramaActividad 
						LEFT JOIN Adinco.dbo.CO_PeriodoContrato PC ON PC.idperiodo = PA.idPeriodoContrato 
						--------------------------------------------------------------------------------------------------
						--------------------------------------------------------------------------------------------------
						LEFT JOIN dbo.CO_CatalogoCuentaSH cuentaSh
								   ON cuentaSh.IdCatalogoCuentasSH = coRegistro.IdCatalogoCuentasSH
						LEFT JOIN Adinco.dbo.CO_Instalacion instalacion
								   ON instalacion.IdInstalacion = coRegistro.IdInstalacion
						LEFT JOIN dbo.S_Usuario usuario
								   ON fiFactura.CreadoPor = usuario.IdUsuarioADINCO
						LEFT JOIN dbo.S_UsuarioProveedor userProv
								   ON userProv.IdUsuario = usuario.IdUsuario
						LEFT JOIN dbo.S_Proveedor prove
								   ON prove.IdProveedor = userProv.IdProveedor
						LEFT JOIN dbo.CO_RegistroPedido RP
								  ON RP.IdFactura = fiFactura.IdFactura
						LEFT JOIN Adinco.dbo.CO_ProgramaActividad progActividad
								   ON progActividad.IdPeriodoContrato = PC.IdPeriodo
						LEFT JOIN Adinco.dbo.CO_Presupuesto presupuesto
								   ON progActividad.IdProgramaActividad = presupuesto.IdProgramaActividad
									  AND	presupuesto.Activo = 1
									  AND	linea.IdPresupuesto = presupuesto.IdPresupuesto
						-----------------------------------------------------------------------------------------------------
						-----------------------------------------------------------------------------------------------------
						LEFT OUTER JOIN Adinco.dbo.CO_ActividadPetroleraCNH AS ACTP
							ON linea.IdActividadPetrolera = ACTP.IdActividadPetrolera
						LEFT OUTER JOIN Adinco.dbo.CO_SubactividadPetrolera AS SACP
							ON linea.IdSubactividadPetrolera = SACP.IdSubactividadPetrolera
						LEFT OUTER JOIN Adinco.dbo.CO_ActividadCIEP AS ACI
							ON linea.IdActividad = ACI.IdActividad
						LEFT OUTER JOIN Adinco.dbo.CO_TipoServicio AS TSC
							ON linea.IdTipoServicio = TSC.ID_TIPOSER
						LEFT OUTER JOIN Adinco.dbo.CO_SubactividadCIEP AS SACI
							ON linea.IdSubactividad = SACI.IdSubactividad
						-----------------------------------------------------------------------------------------------------
						-----------------------------------------------------------------------------------------------------
						LEFT JOIN dbo.TA_Operacion TAO
								   ON TAO.IdDocumento = fiFactura.IdFactura
						LEFT JOIN dbo.MM_Pedidos PG
								   ON PG.IdIdentificador = fiFactura.IdFactura
									  AND	PG.IdTipoPedido = 1
									  AND	TAO.IdProveedor = PG.IdProveedorCliente
						LEFT JOIN dbo.InfoSAT ISAT ON ISAT.Id = 1
				 WHERE
						coRegistro.IdRegistro = @IdRegistro
						AND coRegistro.IdLineaPresupuestoMes = @IdLineaPresupuesto
						AND TAO.IdTipoOperacion = 14
						GROUP BY
								 linea.IdPresupuesto, coRegistro.IdLineaPresupuestoMes, fiFactura.NombreXML, fiFactura.SubTotal ,
								 linea.IdActvidadHidrocarburo, coRegistro.CuentaContable, coRegistro.CentroCostos, coRegistro.MontoRegistro ,
								 coRegistro.InicioEjecucion, coRegistro.FinEjecucion, coRegistro.IdInstalacion, coRegistro.Comentarios ,
								 fiFactura.IdFactura, centroCosto.CentroCosto, cuentaSh.Descripcion, cuentaContable.Descripcion, PG.IdPedido ,
								 fiFactura.Moneda, PC.NombrePeriodo,presupuesto.Nombre,presupuesto.IdPresupuestoCNH, linea.AC_PRESUP_MES,
								 ACTP.DescripcionActividadPetrolera, SACP.SubactividadPetrolera,
								 fiFactura.MontoConIva, coRegistro.IdRegistro, instalacion.NombreInstalacion, prove.RazonSocial, fiFactura.Emisor,
								 P.ciep,ACI.NombreActividad,TSC.NombreTipoServicio,SACI.NombreSubactividad,fiFactura.IdLectorXMLSAT,
								fiFactura.ErroSAT,
								ISAT.DireccionWeb,
								fiFactura.UUID,
								fiFactura.Emisor,
								fiFactura.Receptor,
								PG.CuentaBancaria,
								PG.DiasCredito
				 ORDER BY coRegistro.IdRegistro DESC

			END 
		ELSE
			BEGIN
				--tabla[1] Se Obtiene los soportes de la factura
				SELECT	idFactura AS IdFactura ,	--IdDocumento
						'' ,						--Descripcion
						'' AS Documento, 
						nombreArchivo AS NombreArchivo,
						Carpeta,
						Mime,
						Extension,
						Identificador,
						id
				  FROM	dbo.Pv_DocSoporte_CompraDirecta
				 WHERE	IdFactura = @IdFactura 
				 AND ISNULL(isEliminado,0)=0
			END 
	END 



