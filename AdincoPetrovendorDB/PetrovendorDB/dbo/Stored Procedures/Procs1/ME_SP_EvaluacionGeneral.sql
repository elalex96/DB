-- =============================================
-- Author:		DANIEL AC 
-- Create date: <26-09-2019>
-- Description:	Validación de la tabla CF_EdoCuentaDocumentos bit de ISNULL(isEliminado,0)=0
-- =============================================
CREATE procedure [dbo].[ME_SP_EvaluacionGeneral] 
	@IdProveedor INT,
	/*--------------------parametros contrato  --------------------*/
    @IdContrato    INT = null,
    @IdUsuario     INT = null,
    @FechaRegistro DATETIME = null
	/*-------------------------------------------------------------*/
AS
BEGIN
	--Variables para puntuacion guardados
	DECLARE @Puntos1_1 FLOAT, @Puntos1_2 FLOAT, @Puntos1_3 FLOAT, @Puntos1_4 FLOAT, @Puntos1_5 FLOAT, @Puntos1_6 FLOAT, @Puntos1_7 FLOAT, @Puntos1_8 FLOAT, @Puntos1_9 FLOAT, @Puntos1_10 FLOAT, @Puntos1_11 FLOAT, @Puntos1_12 FLOAT, @Puntos1_13 FLOAT, @Puntos1_14 FLOAT, @Puntos1_15 FLOAT, @Puntos1_16 FLOAT, @Puntos1_17 FLOAT, @Puntos1_18 FLOAT, @Puntos1_19 FLOAT, @Puntos1_20 FLOAT, @Puntos1_21 FLOAT, @Puntos1_22 FLOAT, @Puntos1_23 FLOAT, @Puntos1_24 FLOAT, @Puntos1_25 FLOAT, @Puntos1_26 FLOAT, @Puntos1_27 FLOAT, @Puntos1_28 FLOAT,
			@Puntos2_1 FLOAT, @Puntos2_2 FLOAT, @Puntos2_3 FLOAT,
			@Puntos3_1 FLOAT, @Puntos3_2 FLOAT, @Puntos3_3 FLOAT, @Puntos3_4 FLOAT, @Puntos3_5 FLOAT, @Puntos3_6 FLOAT, @Puntos3_7 FLOAT, @Puntos3_8 FLOAT, @Puntos3_9 FLOAT, @Puntos3_10 FLOAT, @Puntos3_11 FLOAT, @Puntos3_12 FLOAT, @Puntos3_13 FLOAT,
			@Puntos4_1 FLOAT, @Puntos4_2 FLOAT, @Puntos4_3 FLOAT, @Puntos4_4 FLOAT, @Puntos4_5 FLOAT, @Puntos4_6 FLOAT, @Puntos4_7 FLOAT,
			@Puntos5_1 FLOAT, @Puntos5_2 FLOAT, @Puntos5_3 FLOAT, @Puntos5_4 FLOAT,
			@Puntos6_1 FLOAT, @Puntos6_2 FLOAT, @Puntos6_3 FLOAT, @Puntos6_4 FLOAT, @Puntos6_5 FLOAT, @Puntos6_6 FLOAT, @Puntos6_7 FLOAT, @Puntos6_8 FLOAT,
			@Puntos7_1 FLOAT, @Puntos7_2 FLOAT, @Puntos7_3 FLOAT,
			@Puntos8_1 FLOAT, @Puntos8_2 FLOAT, @Puntos8_3 FLOAT, @Puntos8_4 FLOAT, @Puntos8_5 FLOAT, @Puntos8_6 FLOAT, @Puntos8_7 FLOAT, @Puntos8_8 FLOAT, @Puntos8_9 FLOAT, @Puntos8_10 FLOAT,
			@Puntos9_1 FLOAT, @Puntos9_2 FLOAT, @Puntos9_3 FLOAT, @Puntos9_4 FLOAT, @Puntos9_5 FLOAT,
			@Puntos10_1 FLOAT
            
	--Recopilacion de puntuaciones
	--Seccion 1
	SET @Puntos1_1 = (SELECT Puntos FROM dbo.ME_EG_ConceptosDetalle WHERE IdConceptoDetalle = 1)
	SET @Puntos1_2 = (SELECT Puntos FROM dbo.ME_EG_ConceptosDetalle WHERE IdConceptoDetalle = 2)
	SET @Puntos1_3 = (SELECT Puntos FROM dbo.ME_EG_ConceptosDetalle WHERE IdConceptoDetalle = 3)
	SET @Puntos1_4 = (SELECT Puntos FROM dbo.ME_EG_ConceptosDetalle WHERE IdConceptoDetalle = 4)
	SET @Puntos1_5 = (SELECT Puntos FROM dbo.ME_EG_ConceptosDetalle WHERE IdConceptoDetalle = 5)
	SET @Puntos1_6 = (SELECT Puntos FROM dbo.ME_EG_ConceptosDetalle WHERE IdConceptoDetalle = 6)
	SET @Puntos1_7 = (SELECT Puntos FROM dbo.ME_EG_ConceptosDetalle WHERE IdConceptoDetalle = 7)
	SET @Puntos1_8 = (SELECT Puntos FROM dbo.ME_EG_ConceptosDetalle WHERE IdConceptoDetalle = 8)
	SET @Puntos1_9 = (SELECT Puntos FROM dbo.ME_EG_ConceptosDetalle WHERE IdConceptoDetalle = 9)
	SET @Puntos1_10 = (SELECT Puntos FROM dbo.ME_EG_ConceptosDetalle WHERE IdConceptoDetalle = 10)
	SET @Puntos1_11 = (SELECT Puntos FROM dbo.ME_EG_ConceptosDetalle WHERE IdConceptoDetalle = 11)
	SET @Puntos1_12 = (SELECT Puntos FROM dbo.ME_EG_ConceptosDetalle WHERE IdConceptoDetalle = 12)
	SET @Puntos1_13 = (SELECT Puntos FROM dbo.ME_EG_ConceptosDetalle WHERE IdConceptoDetalle = 13)
	SET @Puntos1_14 = (SELECT Puntos FROM dbo.ME_EG_ConceptosDetalle WHERE IdConceptoDetalle = 14)
	SET @Puntos1_15 = (SELECT Puntos FROM dbo.ME_EG_ConceptosDetalle WHERE IdConceptoDetalle = 15)
	SET @Puntos1_16 = (SELECT Puntos FROM dbo.ME_EG_ConceptosDetalle WHERE IdConceptoDetalle = 16)
	SET @Puntos1_17 = (SELECT Puntos FROM dbo.ME_EG_ConceptosDetalle WHERE IdConceptoDetalle = 17)
	SET @Puntos1_18 = (SELECT Puntos FROM dbo.ME_EG_ConceptosDetalle WHERE IdConceptoDetalle = 18)
	SET @Puntos1_19 = (SELECT Puntos FROM dbo.ME_EG_ConceptosDetalle WHERE IdConceptoDetalle = 19)
	SET @Puntos1_20 = (SELECT Puntos FROM dbo.ME_EG_ConceptosDetalle WHERE IdConceptoDetalle = 20)
	SET @Puntos1_21 = (SELECT Puntos FROM dbo.ME_EG_ConceptosDetalle WHERE IdConceptoDetalle = 21)
	SET @Puntos1_22 = (SELECT Puntos FROM dbo.ME_EG_ConceptosDetalle WHERE IdConceptoDetalle = 22)
	SET @Puntos1_23 = (SELECT Puntos FROM dbo.ME_EG_ConceptosDetalle WHERE IdConceptoDetalle = 23)
	SET @Puntos1_24 = (SELECT Puntos FROM dbo.ME_EG_ConceptosDetalle WHERE IdConceptoDetalle = 24)
	SET @Puntos1_25 = (SELECT Puntos FROM dbo.ME_EG_ConceptosDetalle WHERE IdConceptoDetalle = 25)
	SET @Puntos1_26 = (SELECT Puntos FROM dbo.ME_EG_ConceptosDetalle WHERE IdConceptoDetalle = 26)
	SET @Puntos1_27 = (SELECT Puntos FROM dbo.ME_EG_ConceptosDetalle WHERE IdConceptoDetalle = 27)
	SET @Puntos1_28 = (SELECT Puntos FROM dbo.ME_EG_ConceptosDetalle WHERE IdConceptoDetalle = 28)

	--Seccion 2
	SET @Puntos2_1 = (SELECT Puntos FROM dbo.ME_EG_ConceptosDetalle WHERE IdConceptoDetalle = 29)
	SET @Puntos2_2 = (SELECT Puntos FROM dbo.ME_EG_ConceptosDetalle WHERE IdConceptoDetalle = 30)
	SET @Puntos2_3 = (SELECT Puntos FROM dbo.ME_EG_ConceptosDetalle WHERE IdConceptoDetalle = 31)

	--Seccion 3
	SET @Puntos3_1 = (SELECT Puntos FROM dbo.ME_EG_ConceptosDetalle WHERE IdConceptoDetalle = 32)
	SET @Puntos3_2 = (SELECT Puntos FROM dbo.ME_EG_ConceptosDetalle WHERE IdConceptoDetalle = 33)
	SET @Puntos3_3 = (SELECT Puntos FROM dbo.ME_EG_ConceptosDetalle WHERE IdConceptoDetalle = 34)
	SET @Puntos3_4 = (SELECT Puntos FROM dbo.ME_EG_ConceptosDetalle WHERE IdConceptoDetalle = 35)
	SET @Puntos3_5 = (SELECT Puntos FROM dbo.ME_EG_ConceptosDetalle WHERE IdConceptoDetalle = 36)
	SET @Puntos3_6 = (SELECT Puntos FROM dbo.ME_EG_ConceptosDetalle WHERE IdConceptoDetalle = 37)
	SET @Puntos3_7 = (SELECT Puntos FROM dbo.ME_EG_ConceptosDetalle WHERE IdConceptoDetalle = 38)
	SET @Puntos3_8 = (SELECT Puntos FROM dbo.ME_EG_ConceptosDetalle WHERE IdConceptoDetalle = 39)
	SET @Puntos3_9 = (SELECT Puntos FROM dbo.ME_EG_ConceptosDetalle WHERE IdConceptoDetalle = 40)
	SET @Puntos3_10 = (SELECT Puntos FROM dbo.ME_EG_ConceptosDetalle WHERE IdConceptoDetalle = 41)
	SET @Puntos3_11 = (SELECT Puntos FROM dbo.ME_EG_ConceptosDetalle WHERE IdConceptoDetalle = 42)
	SET @Puntos3_12 = (SELECT Puntos FROM dbo.ME_EG_ConceptosDetalle WHERE IdConceptoDetalle = 43)
	SET @Puntos3_13 = (SELECT Puntos FROM dbo.ME_EG_ConceptosDetalle WHERE IdConceptoDetalle = 44)

	--Seccion 4
	SET @Puntos4_1 = (SELECT Puntos FROM dbo.ME_EG_ConceptosDetalle WHERE IdConceptoDetalle = 45)
	SET @Puntos4_2 = (SELECT Puntos FROM dbo.ME_EG_ConceptosDetalle WHERE IdConceptoDetalle = 46)
	SET @Puntos4_3 = (SELECT Puntos FROM dbo.ME_EG_ConceptosDetalle WHERE IdConceptoDetalle = 47)
	SET @Puntos4_4 = (SELECT Puntos FROM dbo.ME_EG_ConceptosDetalle WHERE IdConceptoDetalle = 48)
	SET @Puntos4_5 = (SELECT Puntos FROM dbo.ME_EG_ConceptosDetalle WHERE IdConceptoDetalle = 49)
	SET @Puntos4_6 = (SELECT Puntos FROM dbo.ME_EG_ConceptosDetalle WHERE IdConceptoDetalle = 50)
	SET @Puntos4_7 = (SELECT Puntos FROM dbo.ME_EG_ConceptosDetalle WHERE IdConceptoDetalle = 51)

	--Seccion 5
	SET @Puntos5_1 = (SELECT Puntos FROM dbo.ME_EG_ConceptosDetalle WHERE IdConceptoDetalle = 52)
	SET @Puntos5_2 = (SELECT Puntos FROM dbo.ME_EG_ConceptosDetalle WHERE IdConceptoDetalle = 53)
	SET @Puntos5_3 = (SELECT Puntos FROM dbo.ME_EG_ConceptosDetalle WHERE IdConceptoDetalle = 54)
	SET @Puntos5_4 = (SELECT Puntos FROM dbo.ME_EG_ConceptosDetalle WHERE IdConceptoDetalle = 55)

	--Seccion 6
	SET @Puntos6_1 = (SELECT Puntos FROM dbo.ME_EG_ConceptosDetalle WHERE IdConceptoDetalle = 56)
	SET @Puntos6_2 = (SELECT Puntos FROM dbo.ME_EG_ConceptosDetalle WHERE IdConceptoDetalle = 57)
	SET @Puntos6_3 = (SELECT Puntos FROM dbo.ME_EG_ConceptosDetalle WHERE IdConceptoDetalle = 58)
	SET @Puntos6_4 = (SELECT Puntos FROM dbo.ME_EG_ConceptosDetalle WHERE IdConceptoDetalle = 59)
	SET @Puntos6_5 = (SELECT Puntos FROM dbo.ME_EG_ConceptosDetalle WHERE IdConceptoDetalle = 60)
	SET @Puntos6_6 = (SELECT Puntos FROM dbo.ME_EG_ConceptosDetalle WHERE IdConceptoDetalle = 61)
	SET @Puntos6_7 = (SELECT Puntos FROM dbo.ME_EG_ConceptosDetalle WHERE IdConceptoDetalle = 62)
	SET @Puntos6_8 = (SELECT Puntos FROM dbo.ME_EG_ConceptosDetalle WHERE IdConceptoDetalle = 63)

	--Seccion 7
	SET @Puntos7_1 = (SELECT Puntos FROM dbo.ME_EG_ConceptosDetalle WHERE IdConceptoDetalle = 64)
	SET @Puntos7_2 = (SELECT Puntos FROM dbo.ME_EG_ConceptosDetalle WHERE IdConceptoDetalle = 65)
	SET @Puntos7_3 = (SELECT Puntos FROM dbo.ME_EG_ConceptosDetalle WHERE IdConceptoDetalle = 66)

	--Seccion 8
	SET @Puntos8_1 = (SELECT Puntos FROM dbo.ME_EG_ConceptosDetalle WHERE IdConceptoDetalle = 67)
	SET @Puntos8_2 = (SELECT Puntos FROM dbo.ME_EG_ConceptosDetalle WHERE IdConceptoDetalle = 68)
	SET @Puntos8_3 = (SELECT Puntos FROM dbo.ME_EG_ConceptosDetalle WHERE IdConceptoDetalle = 69)
	SET @Puntos8_4 = (SELECT Puntos FROM dbo.ME_EG_ConceptosDetalle WHERE IdConceptoDetalle = 70)
	SET @Puntos8_5 = (SELECT Puntos FROM dbo.ME_EG_ConceptosDetalle WHERE IdConceptoDetalle = 71)
	SET @Puntos8_6 = (SELECT Puntos FROM dbo.ME_EG_ConceptosDetalle WHERE IdConceptoDetalle = 72)
	SET @Puntos8_7 = (SELECT Puntos FROM dbo.ME_EG_ConceptosDetalle WHERE IdConceptoDetalle = 73)
	SET @Puntos8_8 = (SELECT Puntos FROM dbo.ME_EG_ConceptosDetalle WHERE IdConceptoDetalle = 74)
	SET @Puntos8_9 = (SELECT Puntos FROM dbo.ME_EG_ConceptosDetalle WHERE IdConceptoDetalle = 75)
	SET @Puntos8_10 = (SELECT Puntos FROM dbo.ME_EG_ConceptosDetalle WHERE IdConceptoDetalle = 76)

	--Seccion 9
	SET @Puntos9_1 = (SELECT Puntos FROM dbo.ME_EG_ConceptosDetalle WHERE IdConceptoDetalle = 77)		
	SET @Puntos9_2 = (SELECT Puntos FROM dbo.ME_EG_ConceptosDetalle WHERE IdConceptoDetalle = 78)		
	SET @Puntos9_3 = (SELECT Puntos FROM dbo.ME_EG_ConceptosDetalle WHERE IdConceptoDetalle = 79)		
	SET @Puntos9_4 = (SELECT Puntos FROM dbo.ME_EG_ConceptosDetalle WHERE IdConceptoDetalle = 80)		
	SET @Puntos9_5 = (SELECT Puntos FROM dbo.ME_EG_ConceptosDetalle WHERE IdConceptoDetalle = 81)

	--Seccion 10
	SET @Puntos10_1 = (SELECT Puntos FROM dbo.ME_EG_ConceptosDetalle WHERE IdConceptoDetalle = 82)		

	--Variables para confirmar documentos
	DECLARE @Acumulado FLOAT, 
			@DocActaContitutiva INT,
			@DocINERepresentanteLegal INT,
			@DocPoderRL INT,
			@DocRPPC INT,
			@RepresentanteLegal INT,
			@Accionistas INT,
			@EmpresasRelacionadas INT,
			@DomicilioFiscal INT,
			@DocDomicilioFiscal INT,
			@DomiciolioMatriz INT,
			@DomicilioSucursal INT,
			@PerfilSocial INT,
			@DiasCredito INT,
			@DocAltaIMSS INT,
			@ContactosVentas INT,
			@ContactosCompras INT,
			@ContactosTesoreria INT,
			@GiroEmpresarial INT,
			@ClientesPrincipales INT,
			@SociosComerciales INT,
			@Marcas INT,
			@DistribuirAut INT,
			@ProductosServicios INT,
			@SG9000 INT,
			@SG14000 INT,
			@SG18000 INT,
			@SGESR INT,
			@SGIndustriaLimpia INT,
			@SGCapacitacion INT,
			@SGOtra INT,
			@CuentaBancarias INT,
			@DocEstadoCuenta INT,
			@DocFirmadoRL INT,
			@RefComerciales INT,
			@EdoFinAnt INT,
			@EdoFinAntAnt INT,
			@DocDeclaracionFiscal INT,
			@Estrellas INT,
			@PuntuacionFUNDES float,
			@ClasificacionEmp INT,
			@OpinionSAT INT,
			@AñosExperiencia INT,
			@IdOrganigrama INT,
			@IdCurriculum INT,
			@IdSGISO14000 INT,
			@IdSGISO18000 INT,
			@IdSGESR INT,
			@IdSGCapacitacion INT,
			@IdSGOtra INT,
			@IdSGISO9000 INT, 
			@IdSGIndLimpia INT

	SET @IdSGISO14000 = (SELECT IdDocSistemaGestion FROM dbo.PV_DocSistemGestion WHERE DocSistemaGestion like '%ISO 14000%')
	SET @IdSGISO18000 = (SELECT IdDocSistemaGestion FROM dbo.PV_DocSistemGestion WHERE DocSistemaGestion like '%ISO 18000%')
	SET @IdSGESR = (SELECT IdDocSistemaGestion FROM dbo.PV_DocSistemGestion WHERE DocSistemaGestion like '%Certificado de ESR%')
	SET @IdSGCapacitacion = (SELECT IdDocSistemaGestion FROM dbo.PV_DocSistemGestion WHERE DocSistemaGestion like '%Plan de Capacitacion del personal%')
	SET @IdSGOtra = (SELECT IdDocSistemaGestion FROM dbo.PV_DocSistemGestion WHERE DocSistemaGestion like '%Otra Certificacion%')
	SET @IdSGISO9000 = (SELECT IdDocSistemaGestion FROM dbo.PV_DocSistemGestion WHERE DocSistemaGestion like '%ISO 9000%')
	SET @IdSGIndLimpia = (SELECT IdDocSistemaGestion FROM dbo.PV_DocSistemGestion WHERE DocSistemaGestion like '%Certificado Industria Limpia%')

	SET @Acumulado = 0.0

	--obteniendo documentos y datos de otras tablas

	SET @DocActaContitutiva = (SELECT COUNT(IdDocumento) FROM dbo.S_Documento_S3 WHERE IdProveedor = @IdProveedor AND Documento IS NOT NULL AND IdTipoDocumento = 1)
	SET @DocINERepresentanteLegal = (SELECT COUNT(IdDocumento) FROM dbo.S_Documento_S3 WHERE IdProveedor = @IdProveedor AND Documento IS NOT NULL AND IdTipoDocumento = 2)
	SET @DocPoderRL = (SELECT COUNT(IdDocumento) FROM dbo.S_Documento_S3 WHERE IdProveedor = @IdProveedor AND Documento IS NOT NULL AND IdTipoDocumento = 10)
	SET @DocRPPC = (SELECT COUNT(IdDocumento) FROM dbo.S_Documento_S3 WHERE IdProveedor = @IdProveedor AND Documento IS NOT NULL AND IdTipoDocumento = 23)
	SET @GiroEmpresarial = (SELECT COUNT(IdPerfilGiroEmpresarial) FROM dbo.PV_PerfilGiroEmpresarial WHERE idProveedor = @IdProveedor AND Activo = 1)
	SET @RepresentanteLegal = (SELECT COUNT(IdRepresentanteLegal) FROM dbo.DG_RepresentanteLegal WHERE IdProveedor = @IdProveedor)
	SET @EmpresasRelacionadas = (SELECT COUNT(IdRelacion) FROM dbo.PV_RelacionProveedorSubcotratista WHERE IdProveedor = @IdProveedor)
	SET @DomicilioFiscal = (SELECT COUNT(IdDomicilio) FROM dbo.DG_Domicilio WHERE IdProveedor = @IdProveedor AND Activo = 1 AND IdTipoDomicilio = 1)
	SET @DocDomicilioFiscal = (SELECT COUNT(IdDocumento) FROM dbo.S_Documento_S3 WHERE IdProveedor = @IdProveedor AND Documento IS NOT NULL AND IdTipoDocumento = 5)
	SET @Accionistas = (SELECT COUNT(IdAccionista) FROM dbo.DG_Accionista WHERE IdProveedor = @IdProveedor)
	SET @DomiciolioMatriz = (SELECT COUNT(IdDomicilio) FROM dbo.DG_Domicilio WHERE IdProveedor = @IdProveedor AND Activo = 1 AND IdTipoDomicilio = 2)
	SET @DomicilioSucursal = (SELECT COUNT(IdDomicilio) FROM dbo.DG_Domicilio WHERE IdProveedor = @IdProveedor AND Activo = 1 AND IdTipoDomicilio = 4)
	SET @PerfilSocial = (SELECT COUNT(IdPerfilSocial) FROM dbo.PV_PerfilSocial WHERE IdProveedor = @IdProveedor AND SitioWeb <> '')
	SET @DiasCredito = (SELECT MAX(cp.DiasCredito)
							FROM dbo.PV_CondicionesPago AS cp
								INNER JOIN dbo.PV_ContratistaSubContratista AS cc ON cc.IdRelacion = cp.IdContratistaSubContratista AND cc.IsActivo = 1
							WHERE cc.IdContratista = @IdProveedor AND cp.Credito = 1)
	SET @DocAltaIMSS = (SELECT COUNT(IdDocumento) FROM dbo.S_Documento_S3 WHERE IdProveedor = @IdProveedor AND Documento IS NOT NULL AND IdTipoDocumento = 8)
	SET @ContactosVentas = (SELECT COUNT(IdContacto) FROM dbo.S_Contacto_PA WHERE IdProveedor = @IdProveedor AND IdTipoContacto = 1 AND IsEliminado = 0)
	SET @ContactosCompras = (SELECT COUNT(IdContacto) FROM dbo.S_Contacto_PA WHERE IdProveedor = @IdProveedor AND IdTipoContacto = 3 AND IsEliminado = 0)
	SET @ContactosTesoreria = (SELECT COUNT(IdContacto) FROM dbo.S_Contacto_PA WHERE IdProveedor = @IdProveedor AND IdTipoContacto = 4 AND IsEliminado = 0)
	SET @ClientesPrincipales = (SELECT COUNT(IdClientePrincipales) FROM dbo.PV_ClientePrincipales WHERE IdProveedor = @IdProveedor AND Activo = 1)
	SET @SociosComerciales = (SELECT COUNT(IdSocioComercial) FROM dbo.PV_SocioComercial WHERE IdProveedor = @IdProveedor AND Activo = 1)
	SET @Marcas = (SELECT COUNT(IdMarca) FROM dbo.PV_ProveedorRepresentaMarca WHERE IdProveedor = @IdProveedor AND Activo = 1)
	SET @DistribuirAut = (SELECT COUNT(da.IdDistribuidorAutorizado)
							FROM dbo.PV_DistribuidorAutorizado da
								INNER JOIN dbo.S_Documento_S3 d ON d.IdDocumento = da.IdDocumento
							WHERE da.IdProveedor = @IdProveedor AND da.Activo = 1 AND d.Activo = 1 AND d.Documento IS NOT NULL)
	SET @ProductosServicios = (SELECT COUNT(IdMaterial) FROM dbo.MM_Material WHERE IdProveedor = @IdProveedor)
	SET @SG9000 = (SELECT COUNT(IdSistemaGestion) 
						FROM dbo.PV_SistemaGestion
						WHERE IdProveedor = @IdProveedor AND Documento IS NOT NULL AND Activo = 1 AND IdTipoDocSG = @IdSGISO9000)
	SET @SG14000 = (SELECT COUNT(IdSistemaGestion) 
					FROM dbo.PV_SistemaGestion
					WHERE IdProveedor = @IdProveedor AND Documento IS NOT NULL AND Activo = 1 AND IdTipoDocSG = @IdSGISO14000)
	SET @SG18000 = (SELECT COUNT(IdSistemaGestion) 
						FROM dbo.PV_SistemaGestion
						WHERE IdProveedor = @IdProveedor AND Documento IS NOT NULL AND Activo = 1 AND IdTipoDocSG = @IdSGISO18000)
	SET @SGESR = (SELECT COUNT(IdSistemaGestion) 
						FROM dbo.PV_SistemaGestion
						WHERE IdProveedor = @IdProveedor AND Documento IS NOT NULL AND Activo = 1 AND IdTipoDocSG = @IdSGESR)
	SET @SGIndustriaLimpia = (SELECT COUNT(IdSistemaGestion) 
						FROM dbo.PV_SistemaGestion
						WHERE IdProveedor = @IdProveedor AND Documento IS NOT NULL AND Activo = 1 AND IdTipoDocSG = @IdSGIndLimpia)
	SET @SGCapacitacion = (SELECT COUNT(IdSistemaGestion) 
						FROM dbo.PV_SistemaGestion
						WHERE IdProveedor = @IdProveedor AND Documento IS NOT NULL AND Activo = 1 AND IdTipoDocSG = @IdSGCapacitacion)
	SET @SGOtra = (SELECT COUNT(IdSistemaGestion) 
						FROM dbo.PV_SistemaGestion
						WHERE IdProveedor = @IdProveedor AND Documento IS NOT NULL AND Activo = 1 AND IdTipoDocSG = @IdSGOtra)
	SET @CuentaBancarias = (SELECT COUNT(DatoBancarioID) FROM dbo.PV_CuentaBancaria WHERE IdProveedor = @IdProveedor AND IsEliminado = 0)
	SET @DocEstadoCuenta = (SELECT COUNT(IdDocumento) FROM dbo.S_Documento_S3 WHERE IdProveedor = @IdProveedor AND Documento IS NOT NULL AND IdTipoDocumento = 7)
	SET @DocFirmadoRL = (SELECT COUNT(dcb.IdDocCuentaBancaria)
							FROM dbo.PV_CuentaBancaria cb
							INNER JOIN dbo.PV_CuentaBancariaSubContratista cbc ON cbc.IdCuentaBancaria = cb.DatoBancarioID
							INNER JOIN dbo.PV_DocumentoCuentaBancaria dcb ON dcb.IdCuentaBancaria = cbc.IdCtaBancariaProveedor
							WHERE cb.IdProveedor = @IdProveedor AND cb.IsEliminado = 0 AND dcb.IsActivo = 1 AND cbc.IsActivo = 1)
	SET @RefComerciales = (SELECT COUNT(IdReferenciaComercial) FROM dbo.PV_ReferenciasComerciales WHERE Proveedor = @IdProveedor AND ReferenciaActiva = 1)
	SET @EdoFinAnt = (SELECT COUNT(IdEdoCuenta) FROM dbo.CF_EdoCuentaDocumentos WHERE IdProveedor = @IdProveedor AND Año = (DATEPART(YEAR, GETDATE()) - 1) AND EdoCuenta IS NOT NULL AND ISNULL(isEliminado,0)=0)
	SET @EdoFinAntAnt = (SELECT COUNT(IdEdoCuenta) FROM dbo.CF_EdoCuentaDocumentos WHERE IdProveedor = @IdProveedor AND Año = (DATEPART(YEAR, GETDATE()) - 2) AND EdoCuenta IS NOT NULL AND ISNULL(isEliminado,0)=0)
	SET @DocDeclaracionFiscal = (SELECT COUNT(IdDeclaracionFiscal) FROM dbo.CF_DeclaracionFiscal WHERE IdProveedor = @IdProveedor)
	SET @Estrellas = (SELECT dbo.ObtenerEstrellasModificado(@IdProveedor))
	SET @PuntuacionFUNDES = (SELECT MAX(puntaje)/10 FROM dbo.PV_FundesEvaluacion WHERE ProveedorEvaluado = @IdProveedor AND Activo = 1)
	SET @ClasificacionEmp = (SELECT IdClasificacionEmpresa FROM dbo.PV_ClasificacionEmpresaProveedor WHERE IdProveedor = @IdProveedor)
	SET @OpinionSAT = (SELECT Opinion FROM dbo.CF_CartaOpinionSAT WHERE IdProveedor = @IdProveedor AND Eliminado = 0 AND Carta IS NOT NULL AND vigente = 1)
	SET @AñosExperiencia = (SELECT AniosExperiencia FROM dbo.PV_PerfilEmpresa WHERE IdProveedor = @IdProveedor)
	SET @IdCurriculum = (SELECT IdDocumentoCurriculum FROM dbo.PV_PerfilEmpresa WHERE IdProveedor = @IdProveedor)
	SET @IdOrganigrama = (SELECT IdDocumentoOrganigrama FROM dbo.PV_PerfilEmpresa WHERE IdProveedor = @IdProveedor)
	
	--Guardado de respuestas:
	DELETE dbo.ME_EG_ConceptosCompletados WHERE IdProveedor = @IdProveedor

	INSERT INTO dbo.ME_EG_ConceptosCompletados (IdProveedor, Completado, IdConcepto)
	select @IdProveedor, (CASE WHEN IdNacionalidad IS NULL THEN 0 ELSE @Puntos1_1 END), 1
	from dbo.S_Proveedor WHERE IdProveedor = @IdProveedor

	INSERT INTO dbo.ME_EG_ConceptosCompletados (IdProveedor, Completado, IdConcepto)
	select @IdProveedor, (CASE WHEN IdTipoRegimen = 2 THEN @Puntos1_2 WHEN IdTipoRegimen <> 2 THEN @Puntos1_3 ELSE 0 END), 2
	from dbo.S_Proveedor WHERE IdProveedor = @IdProveedor

	INSERT INTO dbo.ME_EG_ConceptosCompletados (IdProveedor, Completado, IdConcepto)
	select @IdProveedor, (CASE WHEN RFC IS NULL THEN 0 ELSE @Puntos1_4 END), 3
	from dbo.S_Proveedor WHERE IdProveedor = @IdProveedor

	INSERT INTO dbo.ME_EG_ConceptosCompletados (IdProveedor, Completado, IdConcepto)
	select @IdProveedor, (CASE WHEN RazonSocial IS NOT NULL THEN @Puntos1_5 ELSE 0 END), 4
	from dbo.S_Proveedor WHERE IdProveedor = @IdProveedor

	INSERT INTO dbo.ME_EG_ConceptosCompletados (IdProveedor, Completado, IdConcepto)
	select @IdProveedor, (CASE WHEN Alias IS NULL THEN 0 ELSE @Puntos1_6 END), 5
	from dbo.S_Proveedor WHERE IdProveedor = @IdProveedor

	INSERT INTO dbo.ME_EG_ConceptosCompletados (IdProveedor, Completado, IdConcepto)
	select @IdProveedor, (CASE WHEN @RepresentanteLegal > 0 AND @DocINERepresentanteLegal > 0 and IdTipoRegimen <> 2 THEN @Puntos1_7 
							   WHEN @DocINERepresentanteLegal > 0 AND IdTipoRegimen = 2 THEN @Puntos1_7 ELSE 0 END), 6
	from dbo.S_Proveedor WHERE IdProveedor = @IdProveedor
	
	INSERT INTO dbo.ME_EG_ConceptosCompletados (IdProveedor, Completado, IdConcepto)
	select @IdProveedor, (CASE WHEN CURP IS NULL THEN 0 ELSE @Puntos1_8 END), 7
	from dbo.S_Proveedor WHERE IdProveedor = @IdProveedor
	
	INSERT INTO dbo.ME_EG_ConceptosCompletados (IdProveedor, Completado, IdConcepto)
	select @IdProveedor, (case when @DocPoderRL > 0 and IdTipoRegimen <> 2 then @Puntos1_9 else 0 end), 8
	from dbo.S_Proveedor WHERE IdProveedor = @IdProveedor
	
	INSERT INTO dbo.ME_EG_ConceptosCompletados (IdProveedor, Completado, IdConcepto)
	select @IdProveedor, (CASE WHEN @DocRPPC > 0 and IdTipoRegimen <> 2 AND @DocActaContitutiva > 0 THEN @Puntos1_10 ELSE 0 END), 9
	from dbo.S_Proveedor WHERE IdProveedor = @IdProveedor
	
	INSERT INTO dbo.ME_EG_ConceptosCompletados (IdProveedor, Completado, IdConcepto)
	select @IdProveedor, (CASE WHEN @Accionistas > 0 and IdTipoRegimen <> 2 THEN @Puntos1_12 ELSE 0 END), 11
	from dbo.S_Proveedor WHERE IdProveedor = @IdProveedor

	INSERT INTO dbo.ME_EG_ConceptosCompletados (IdProveedor, Completado, IdConcepto)
	select @IdProveedor, (CASE WHEN IdTipoRegimen <> 2 then @Puntos1_13 else 0 END), 12
	from dbo.S_Proveedor WHERE IdProveedor = @IdProveedor

	INSERT INTO dbo.ME_EG_ConceptosCompletados (IdProveedor, Completado, IdConcepto)
	select @IdProveedor, (CASE WHEN @EmpresasRelacionadas = 0 and IdTipoRegimen = 2 THEN 0 ELSE @puntos1_14 END), 13
	from dbo.S_Proveedor WHERE IdProveedor = @IdProveedor
	
	INSERT INTO dbo.ME_EG_ConceptosCompletados (IdProveedor, Completado, IdConcepto)
	select @IdProveedor, (CASE WHEN Telefono IS NULL THEN 0 ELSE @puntos1_16 END), 15
	from dbo.S_Proveedor WHERE IdProveedor = @IdProveedor
	
	INSERT INTO dbo.ME_EG_ConceptosCompletados (IdProveedor, Completado, IdConcepto)
	select @IdProveedor, (CASE WHEN MonedaFacturar = 1 THEN @Puntos1_20 ELSE 0 END), 19
	from dbo.S_Proveedor WHERE IdProveedor = @IdProveedor

	INSERT INTO dbo.ME_EG_ConceptosCompletados (IdProveedor, Completado, IdConcepto)
	select @IdProveedor, (CASE WHEN @DocRPPC > 0 and IdTipoRegimen <> 2 THEN @Puntos1_26 else 0 END), 21
	from dbo.S_Proveedor WHERE IdProveedor = @IdProveedor
	
	INSERT INTO dbo.ME_EG_ConceptosCompletados (IdProveedor, Completado, IdConcepto)
	select @IdProveedor, (CASE WHEN InhabilitadoSFP = 0 and AnteriorInhabilitadoSFP = 0 THEN @Puntos1_27 ELSE 0 END), 22
	from dbo.S_Proveedor WHERE IdProveedor = @IdProveedor
		
	INSERT INTO dbo.ME_EG_ConceptosCompletados (IdProveedor, Completado, IdConcepto)
	VALUES  (@IdProveedor, (CASE WHEN @GiroEmpresarial > 0 THEN @Puntos1_11 ELSE 0 END), 10),
			(@IdProveedor, (CASE WHEN @DomicilioFiscal > 0 AND @DocDomicilioFiscal > 0 THEN @Puntos1_15 ELSE 0 END), 14),
			(@IdProveedor, (CASE WHEN @DomiciolioMatriz > 0 THEN @Puntos1_17 ELSE 0 END), 16),
			(@IdProveedor, (CASE WHEN @DomicilioSucursal > 0 THEN @Puntos1_18 ELSE 0 END), 17),
			(@IdProveedor, (CASE WHEN @PerfilSocial > 0 THEN @Puntos1_19 ELSE 0 END), 18),
			(@IdProveedor, (CASE WHEN @DiasCredito = 15 THEN @Puntos1_21
									WHEN @DiasCredito = 30 THEN @Puntos1_22
									WHEN @DiasCredito = 45 THEN @Puntos1_23
									WHEN @DiasCredito = 60 THEN @Puntos1_24
									WHEN @DiasCredito = 90 THEN @Puntos1_25 ELSE 0 END), 20),
			(@IdProveedor, (CASE WHEN @DocAltaIMSS > 0 THEN @Puntos1_28 ELSE 0 END), 23),
			(@IdProveedor, (CASE WHEN @ContactosVentas > 0 THEN @Puntos2_1 ELSE	0 END), 24),
			(@IdProveedor, (CASE WHEN @ContactosCompras > 0 THEN @Puntos2_2 ELSE	0 END), 25),
			(@IdProveedor, (CASE WHEN @ContactosTesoreria > 0 THEN @Puntos2_3 ELSE 0 END), 26),
			(@IdProveedor, @Puntos3_1, 27),
			(@IdProveedor, (CASE WHEN @AñosExperiencia = 1 THEN @Puntos3_2
									WHEN @AñosExperiencia >= 2 and @AñosExperiencia <= 3 THEN @Puntos3_3
									WHEN @AñosExperiencia >= 4 AND @AñosExperiencia <= 5 THEN @Puntos3_4
									WHEN @AñosExperiencia >= 6 AND @AñosExperiencia <= 8 THEN @Puntos3_5
									WHEN @AñosExperiencia > 8 THEN @Puntos3_6 ELSE 0 END), 28),
			(@IdProveedor, (CASE WHEN @ClientesPrincipales > 0 THEN @Puntos3_7 ELSE 0 END), 29),
			(@IdProveedor, (CASE WHEN @SociosComerciales > 0 THEN @Puntos3_8 ELSE 0 END), 30),
			(@IdProveedor, (CASE WHEN @Marcas > 0 THEN @Puntos3_9 ELSE 0 END), 31),
			(@IdProveedor, (CASE WHEN @DistribuirAut > 0 THEN @Puntos3_10 ELSE 0 END), 32),
			(@IdProveedor, (CASE WHEN @ProductosServicios > 0 THEN @Puntos3_11 ELSE 0 END), 33),
			(@IdProveedor, (CASE WHEN @IdCurriculum IS NULL THEN 0 ELSE @Puntos3_12 END), 34),
			(@IdProveedor, (CASE WHEN @IdOrganigrama IS NULL THEN 0 ELSE @Puntos3_13 END), 35),
			(@IdProveedor, (CASE WHEN @SG9000 > 0 THEN @Puntos4_1 ELSE 0 END), 36),
			(@IdProveedor, (CASE WHEN @SG14000 > 0 THEN @Puntos4_2 ELSE 0 END), 37),
			(@IdProveedor, (CASE WHEN @SG18000 > 0 THEN @Puntos4_3 ELSE 0 END), 38),
			(@IdProveedor, (CASE WHEN @SGESR > 0 THEN @Puntos4_4 ELSE 0 END), 39),
			(@IdProveedor, (CASE WHEN @SGIndustriaLimpia > 0 THEN @Puntos4_5 ELSE 0 END), 40),
			(@IdProveedor, (CASE WHEN @SGCapacitacion > 0 THEN @Puntos4_6 ELSE 0 END), 41),
			(@IdProveedor, (CASE WHEN @SGOtra > 0 THEN @Puntos4_7 ELSE 0 END), 42),
			(@IdProveedor, (CASE WHEN @ClasificacionEmp = 1 THEN @Puntos5_1
									WHEN @ClasificacionEmp = 2 THEN @Puntos5_2
									WHEN @ClasificacionEmp = 3 THEN @Puntos5_3 
									WHEN @ClasificacionEmp = 4 THEN @Puntos5_4 ELSE 0 END), 43),
			(@IdProveedor, (CASE WHEN @CuentaBancarias > 0 THEN @Puntos6_1 ELSE 0 END), 44),
			(@IdProveedor, (CASE WHEN @CuentaBancarias > 0 THEN @Puntos6_2 ELSE 0 END), 45),
			(@IdProveedor, (CASE WHEN @CuentaBancarias > 0 THEN @Puntos6_3 ELSE 0 END), 46),
			(@IdProveedor, (CASE WHEN @CuentaBancarias > 0 THEN @Puntos6_4 ELSE 0 END), 47),
			(@IdProveedor, (CASE WHEN @CuentaBancarias > 0 THEN @Puntos6_5 ELSE 0 END), 48),
			(@IdProveedor, (CASE WHEN @CuentaBancarias > 0 THEN @Puntos6_6 ELSE 0 END), 49),
			(@IdProveedor, (CASE WHEN @DocEstadoCuenta > 0 THEN @Puntos6_7 ELSE 0 END), 50),
			(@IdProveedor, (case when @DocFirmadoRL > 0 then @Puntos6_8 else 0 end), 51),
			(@IdProveedor, (CASE WHEN @RefComerciales > 0 AND @RefComerciales < 3 THEN @Puntos7_1
									WHEN @RefComerciales > 2 AND @RefComerciales < 6 THEN @Puntos7_2
									WHEN @RefComerciales > 5 THEN @Puntos7_3 ELSE 0 END), 52),
			(@IdProveedor, (CASE WHEN @EdoFinAnt > 0 THEN @Puntos8_7 ELSE 0 END), 54),
			(@IdProveedor, (CASE WHEN @EdoFinAntAnt > 0 THEN @puntos8_8 ELSE 0 END), 55),
			(@IdProveedor, (CASE WHEN @DocDeclaracionFiscal > 0 THEN @Puntos8_9 ELSE 0 END), 56),
			(@IdProveedor, (case when @OpinionSAT = 1 then @Puntos8_10 ELSE 0 end), 57),
			(@IdProveedor, (CASE WHEN @Estrellas = 1 THEN @Puntos9_1
									WHEN @Estrellas = 2 THEN @Puntos9_2
									WHEN @Estrellas = 3 THEN @Puntos9_3
									WHEN @Estrellas = 4 THEN @Puntos9_4
									WHEN @Estrellas = 5 THEN @Puntos9_5 ELSE 0 END), 58),
			(@IdProveedor, 0, 59)

	INSERT INTO dbo.ME_EG_ConceptosCompletados (IdProveedor, Completado, IdConcepto)
	select @IdProveedor, (CASE WHEN CapitalContable > 0 AND CapitalContable < 1000001 THEN @Puntos8_1 
									WHEN CapitalContable > 1000000 AND CapitalContable < 3000001 THEN @Puntos8_2
									WHEN CapitalContable > 3000000 AND CapitalContable < 7000001 THEN @Puntos8_3
									WHEN CapitalContable > 7000000 AND CapitalContable < 15000001 THEN @Puntos8_4
									WHEN CapitalContable > 15000000 AND CapitalContable < 25000001 THEN @Puntos8_5
									WHEN CapitalContable > 25000000 THEN @Puntos8_6 ELSE 0 END), 53
	from dbo.S_Proveedor WHERE IdProveedor = @IdProveedor

	DECLARE @Existe INT
	SET @Acumulado = (SELECT SUM(Completado) FROM ME_EG_ConceptosCompletados WHERE IdProveedor = @IdProveedor)

	SET @Existe = (SELECT COUNT(idResultadoEG) FROM me_resultadoEG WHERE idproveedor = @IdProveedor)
	IF(@Existe > 0)
	BEGIN
		UPDATE dbo.ME_ResultadoEG
			SET Resultado = @Acumulado
			WHERE IdProveedor = @IdProveedor
	END	
	ELSE
    BEGIN
		INSERT INTO dbo.ME_ResultadoEG
		(
		    IdProveedor,
		    Resultado
		)
		VALUES
		(   @IdProveedor,  -- IdProveedor - int
		    @Acumulado	   -- Resultado - float
		) 
	end

	SELECT @Acumulado
END


