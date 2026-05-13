
-- =============================================
-- Author:		<Jose Roman>
-- Create date: <24-07-2018>
-- Description:	<Se crea el calculo para la Evaluación Interna>
-- =============================================
-- =============================================
-- Author:		Daniel AC
-- Create date: <26-09-2019>
-- Description:	Agregue validación en CF_EdoCuentaDocumentos que no este con el bit de eliminado
-- =============================================
CREATE procedure [dbo].[EI_CalculoEvaluacionInterna]
	@IdProveedor INT,
	/*--------------------parametros contrato  --------------------*/
    @IdContrato    INT = null,
    @IdUsuario     INT = null,
    @FechaRegistro DATETIME = null
	/*-------------------------------------------------------------*/
AS
BEGIN
	--Puntos para evaluación interna
	DECLARE @Puntos1_1 FLOAT, @Puntos1_2 FLOAT, @Puntos1_3 FLOAT, @Puntos1_4 FLOAT, @Puntos1_5 FLOAT, @Puntos1_6 FLOAT, @Puntos1_7 FLOAT, @Puntos1_8 FLOAT, @Puntos1_9 FLOAT, @Puntos1_10 FLOAT, @Puntos1_11 FLOAT, @Puntos1_12 FLOAT, @Puntos1_13 FLOAT,
			@Puntos2_1 FLOAT,
			@Puntos3_1 FLOAT, 
			@Puntos4_1 FLOAT, @Puntos4_2 FLOAT, @Puntos4_3 FLOAT, @Puntos4_4 FLOAT,
			@Puntos5_1 FLOAT, @Puntos5_2 FLOAT, @Puntos5_3 FLOAT, @Puntos5_4 FLOAT, @Puntos5_5 FLOAT, @Puntos5_6 FLOAT, @Puntos5_7 FLOAT, @Puntos5_8 FLOAT,
			@Puntos6_1 FLOAT, @Puntos6_2 FLOAT, @Puntos6_3 FLOAT, @Puntos6_4 FLOAT, @Puntos6_5 FLOAT, @Puntos6_6 FLOAT, @Puntos6_7 FLOAT,
			@Puntos7_1 FLOAT,
			@Puntos8_1 FLOAT, @Puntos8_2 FLOAT, @Puntos8_3 FLOAT, @Puntos8_4 FLOAT,
			@Puntos9_1 FLOAT, 
			@Puntos10_1 FLOAT,
			@Puntos11_1 FLOAT, @Puntos11_2 FLOAT, @Puntos11_3 FLOAT, @Puntos11_4 FLOAT, @Puntos11_5 FLOAT, @Puntos11_6 FLOAT, @Puntos11_7 FLOAT, @Puntos11_8 FLOAT, @Puntos11_9 FLOAT, @Puntos11_10 FLOAT,
			@Puntos12_1 FLOAT,
			@Puntos13_1 FLOAT, @Puntos13_2 FLOAT, @Puntos13_3 FLOAT,
			@TipoRegimen INT

	SET @TipoRegimen = (SELECT IdTipoRegimen FROM dbo.S_Proveedor WHERE IdProveedor = @IdProveedor)

	--Recopilacion de puntuaciones
	SET @Puntos1_1 = (SELECT Puntos FROM dbo.EI_ConceptosDetalle WHERE IdConceptoDetalle = 1)
	SET @Puntos1_2 = (SELECT Puntos FROM dbo.EI_ConceptosDetalle WHERE IdConceptoDetalle = 2)
	SET @Puntos1_3 = (SELECT Puntos FROM dbo.EI_ConceptosDetalle WHERE IdConceptoDetalle = 3)
	SET @Puntos1_4 = (SELECT Puntos FROM dbo.EI_ConceptosDetalle WHERE IdConceptoDetalle = 4)
	SET @Puntos1_5 = (SELECT Puntos FROM dbo.EI_ConceptosDetalle WHERE IdConceptoDetalle = 5)
	SET @Puntos1_6 = (SELECT Puntos FROM dbo.EI_ConceptosDetalle WHERE IdConceptoDetalle = 6)
	SET @Puntos1_7 = (SELECT Puntos FROM dbo.EI_ConceptosDetalle WHERE IdConceptoDetalle = 7)
	SET @Puntos1_8 = (SELECT Puntos FROM dbo.EI_ConceptosDetalle WHERE IdConceptoDetalle = 8)
	SET @Puntos1_9 = (SELECT Puntos FROM dbo.EI_ConceptosDetalle WHERE IdConceptoDetalle = 9)
	SET @Puntos1_10 = (SELECT Puntos FROM dbo.EI_ConceptosDetalle WHERE IdConceptoDetalle = 10)
	SET @Puntos1_11 = (SELECT Puntos FROM dbo.EI_ConceptosDetalle WHERE IdConceptoDetalle = 11)
	SET @Puntos1_12 = (SELECT Puntos FROM dbo.EI_ConceptosDetalle WHERE IdConceptoDetalle = 12)
	SET @Puntos1_13 = (SELECT Puntos FROM dbo.EI_ConceptosDetalle WHERE IdConceptoDetalle = 13)

	SET @Puntos2_1 = (SELECT Puntos FROM dbo.EI_ConceptosDetalle WHERE IdConceptoDetalle = 14)

	SET @Puntos3_1 = (SELECT Puntos FROM dbo.EI_ConceptosDetalle WHERE IdConceptoDetalle = 15)

	SET @Puntos4_1 = (SELECT Puntos FROM dbo.EI_ConceptosDetalle WHERE IdConceptoDetalle = 16)
	SET @Puntos4_2 = (SELECT Puntos FROM dbo.EI_ConceptosDetalle WHERE IdConceptoDetalle = 17)
	SET @Puntos4_3 = (SELECT Puntos FROM dbo.EI_ConceptosDetalle WHERE IdConceptoDetalle = 18)
	SET @Puntos4_4 = (SELECT Puntos FROM dbo.EI_ConceptosDetalle WHERE IdConceptoDetalle = 19)

	SET @Puntos5_1 = (SELECT Puntos FROM dbo.EI_ConceptosDetalle WHERE IdConceptoDetalle = 20)
	SET @Puntos5_2 = (SELECT Puntos FROM dbo.EI_ConceptosDetalle WHERE IdConceptoDetalle = 21)
	SET @Puntos5_3 = (SELECT Puntos FROM dbo.EI_ConceptosDetalle WHERE IdConceptoDetalle = 22)
	SET @Puntos5_4 = (SELECT Puntos FROM dbo.EI_ConceptosDetalle WHERE IdConceptoDetalle = 23)
	SET @Puntos5_5 = (SELECT Puntos FROM dbo.EI_ConceptosDetalle WHERE IdConceptoDetalle = 24)
	SET @Puntos5_6 = (SELECT Puntos FROM dbo.EI_ConceptosDetalle WHERE IdConceptoDetalle = 25)
	SET @Puntos5_7 = (SELECT Puntos FROM dbo.EI_ConceptosDetalle WHERE IdConceptoDetalle = 26)
	SET @Puntos5_8 = (SELECT Puntos FROM dbo.EI_ConceptosDetalle WHERE IdConceptoDetalle = 27)

	SET @Puntos6_1 = (SELECT Puntos FROM dbo.EI_ConceptosDetalle WHERE IdConceptoDetalle = 28)
	SET @Puntos6_2 = (SELECT Puntos FROM dbo.EI_ConceptosDetalle WHERE IdConceptoDetalle = 29)
	SET @Puntos6_3 = (SELECT Puntos FROM dbo.EI_ConceptosDetalle WHERE IdConceptoDetalle = 30)
	SET @Puntos6_4 = (SELECT Puntos FROM dbo.EI_ConceptosDetalle WHERE IdConceptoDetalle = 31)
	SET @Puntos6_5 = (SELECT Puntos FROM dbo.EI_ConceptosDetalle WHERE IdConceptoDetalle = 32)
	SET @Puntos6_6 = (SELECT Puntos FROM dbo.EI_ConceptosDetalle WHERE IdConceptoDetalle = 33)
	SET @Puntos6_7 = (SELECT Puntos FROM dbo.EI_ConceptosDetalle WHERE IdConceptoDetalle = 34)

	SET @Puntos7_1 = (SELECT Puntos FROM dbo.EI_ConceptosDetalle WHERE IdConceptoDetalle = 35)

	SET @Puntos8_1 = (SELECT Puntos FROM dbo.EI_ConceptosDetalle WHERE IdConceptoDetalle = 36)
	SET @Puntos8_2 = (SELECT Puntos FROM dbo.EI_ConceptosDetalle WHERE IdConceptoDetalle = 37)
	SET @Puntos8_3 = (SELECT Puntos FROM dbo.EI_ConceptosDetalle WHERE IdConceptoDetalle = 38)
	SET @Puntos8_4 = (SELECT Puntos FROM dbo.EI_ConceptosDetalle WHERE IdConceptoDetalle = 39)

	SET @Puntos9_1 = (SELECT Puntos FROM dbo.EI_ConceptosDetalle WHERE IdConceptoDetalle = 40)

	SET @Puntos10_1 = (SELECT Puntos FROM dbo.EI_ConceptosDetalle WHERE IdConceptoDetalle = 41)

	SET @Puntos11_1 = (SELECT Puntos FROM dbo.EI_ConceptosDetalle WHERE IdConceptoDetalle = 42)
	SET @Puntos11_2 = (SELECT Puntos FROM dbo.EI_ConceptosDetalle WHERE IdConceptoDetalle = 43)
	SET @Puntos11_3 = (SELECT Puntos FROM dbo.EI_ConceptosDetalle WHERE IdConceptoDetalle = 44)
	SET @Puntos11_4 = (SELECT Puntos FROM dbo.EI_ConceptosDetalle WHERE IdConceptoDetalle = 45)
	SET @Puntos11_5 = (SELECT Puntos FROM dbo.EI_ConceptosDetalle WHERE IdConceptoDetalle = 46)
	SET @Puntos11_6 = (SELECT Puntos FROM dbo.EI_ConceptosDetalle WHERE IdConceptoDetalle = 47)
	SET @Puntos11_7 = (SELECT Puntos FROM dbo.EI_ConceptosDetalle WHERE IdConceptoDetalle = 48)
	SET @Puntos11_8 = (SELECT Puntos FROM dbo.EI_ConceptosDetalle WHERE IdConceptoDetalle = 49)
	SET @Puntos11_9 = (SELECT Puntos FROM dbo.EI_ConceptosDetalle WHERE IdConceptoDetalle = 50)
	SET @Puntos11_10 = (SELECT Puntos FROM dbo.EI_ConceptosDetalle WHERE IdConceptoDetalle = 51)

	SET @Puntos12_1 = (SELECT Puntos FROM dbo.EI_ConceptosDetalle WHERE IdConceptoDetalle = 52)

	SET @Puntos13_1 = (SELECT Puntos FROM dbo.EI_ConceptosDetalle WHERE IdConceptoDetalle = 53)
	SET @Puntos13_2 = (SELECT Puntos FROM dbo.EI_ConceptosDetalle WHERE IdConceptoDetalle = 54)
	SET @Puntos13_3 = (SELECT Puntos FROM dbo.EI_ConceptosDetalle WHERE IdConceptoDetalle = 55)

	--Variables auxiliares para validar documentos
	DECLARE @IdSGISO14000 INT,
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

	--Guardado de respuestas
	DELETE dbo.EI_ConceptosCompletados WHERE IdProveedor = @IdProveedor

	INSERT INTO dbo.EI_ConceptosCompletados (IdProveedor, Completado, IdConceptoDetalle)
	select @IdProveedor, (CASE WHEN IdTipoRegimen IS NULL THEN 0 ELSE @Puntos1_1 END), 1
	from dbo.S_Proveedor WHERE IdProveedor = @IdProveedor
	
	INSERT INTO dbo.EI_ConceptosCompletados (IdProveedor, Completado, IdConceptoDetalle)
	select @IdProveedor, (CASE WHEN RFC IS NULL THEN 0 ELSE @Puntos1_2 END), 2
	from dbo.S_Proveedor WHERE IdProveedor = @IdProveedor
	
	INSERT INTO dbo.EI_ConceptosCompletados (IdProveedor, Completado, IdConceptoDetalle)
	select @IdProveedor, (CASE WHEN IdNacionalidad IS NULL THEN 0 ELSE @Puntos1_3 END), 3
	from dbo.S_Proveedor WHERE IdProveedor = @IdProveedor
	
	INSERT INTO dbo.EI_ConceptosCompletados (IdProveedor, Completado, IdConceptoDetalle)
	select @IdProveedor, (CASE WHEN RazonSocial IS NULL THEN 0 ELSE @Puntos1_4 END), 4
	from dbo.S_Proveedor WHERE IdProveedor = @IdProveedor

	INSERT INTO dbo.EI_ConceptosCompletados (IdProveedor, Completado, IdConceptoDetalle)
	select @IdProveedor, (CASE WHEN RegimenCapital IS NULL THEN 0 ELSE @Puntos1_5 END), 5
	from dbo.S_Proveedor WHERE IdProveedor = @IdProveedor
	
	INSERT INTO dbo.EI_ConceptosCompletados (IdProveedor, Completado, IdConceptoDetalle)
	select @IdProveedor, (CASE WHEN Alias IS NULL THEN 0 ELSE @Puntos1_6 END), 6
	from dbo.S_Proveedor WHERE IdProveedor = @IdProveedor
	
	INSERT INTO dbo.EI_ConceptosCompletados (IdProveedor, Completado, IdConceptoDetalle)
	select @IdProveedor, (CASE WHEN FechaConstitucion IS NULL THEN 0 ELSE @Puntos1_7 END), 7
	from dbo.S_Proveedor WHERE IdProveedor = @IdProveedor
	
	INSERT INTO dbo.EI_ConceptosCompletados (IdProveedor, Completado, IdConceptoDetalle)
	select @IdProveedor, (CASE WHEN IMSS IS NULL THEN 0 ELSE @Puntos1_8 END), 8
	from dbo.S_Proveedor WHERE IdProveedor = @IdProveedor
	
	INSERT INTO dbo.EI_ConceptosCompletados (IdProveedor, Completado, IdConceptoDetalle)
	select @IdProveedor, (CASE WHEN MonedaFacturar IS NULL THEN 0 ELSE @Puntos1_9 END), 9
	from dbo.S_Proveedor WHERE IdProveedor = @IdProveedor

	INSERT INTO dbo.EI_ConceptosCompletados (IdProveedor, Completado, IdConceptoDetalle)
	select @IdProveedor, (CASE WHEN Telefono IS NULL THEN 0 ELSE @Puntos1_10 END), 10
	from dbo.S_Proveedor WHERE IdProveedor = @IdProveedor
	
	INSERT INTO dbo.EI_ConceptosCompletados (IdProveedor, Completado, IdConceptoDetalle)
	select @IdProveedor, (CASE WHEN CURP IS NULL THEN 0 ELSE @Puntos1_11 END), 11
	from dbo.S_Proveedor WHERE IdProveedor = @IdProveedor
	
	INSERT INTO dbo.EI_ConceptosCompletados (IdProveedor, Completado, IdConceptoDetalle)
	select @IdProveedor, (CASE WHEN RPPC IS NULL THEN 0 ELSE @Puntos1_12 END), 12
	from dbo.S_Proveedor WHERE IdProveedor = @IdProveedor
	
	INSERT INTO dbo.EI_ConceptosCompletados (IdProveedor, Completado, IdConceptoDetalle)
	select @IdProveedor, (CASE WHEN InhabilitadoSFP IS NULL THEN 0 ELSE @Puntos1_13 END), 13
	from dbo.S_Proveedor WHERE IdProveedor = @IdProveedor
	
	INSERT INTO dbo.EI_ConceptosCompletados (IdProveedor, Completado, IdConceptoDetalle)
	SELECT @IdProveedor, (CASE WHEN COUNT(IdRelacion) = 0 THEN 0 ELSE @puntos2_1 END), 14
	FROM dbo.PV_RelacionProveedorSubcotratista WHERE IdProveedor = @IdProveedor
	
	INSERT INTO dbo.EI_ConceptosCompletados (IdProveedor, Completado, IdConceptoDetalle)
	SELECT @IdProveedor, (CASE WHEN COUNT(IdDomicilio) = 0 THEN 0 ELSE @Puntos3_1 END), 15
	FROM dbo.DG_Domicilio WHERE IdProveedor = @IdProveedor AND Activo = 1 
		
	INSERT INTO dbo.EI_ConceptosCompletados (IdProveedor, Completado, IdConceptoDetalle)
	SELECT @IdProveedor, (CASE WHEN COUNT(IdContacto) = 0 THEN 0 ELSE @Puntos4_1 END), 16
	FROM dbo.S_Contacto_PA WHERE IdProveedor = @IdProveedor AND IdTipoContacto = 1 AND IsEliminado = 0
	
	INSERT INTO dbo.EI_ConceptosCompletados (IdProveedor, Completado, IdConceptoDetalle)
	SELECT @IdProveedor, (CASE WHEN COUNT(IdContacto) = 0 THEN 0 ELSE @Puntos4_2 END), 17
	FROM dbo.S_Contacto_PA WHERE IdProveedor = @IdProveedor AND IdTipoContacto = 2 AND IsEliminado = 0
	
	INSERT INTO dbo.EI_ConceptosCompletados (IdProveedor, Completado, IdConceptoDetalle)
	SELECT @IdProveedor, (CASE WHEN COUNT(IdContacto) = 0 THEN 0 ELSE @Puntos4_3 END), 18
	FROM dbo.S_Contacto_PA WHERE IdProveedor = @IdProveedor AND IdTipoContacto = 3 AND IsEliminado = 0
	
	INSERT INTO dbo.EI_ConceptosCompletados (IdProveedor, Completado, IdConceptoDetalle)
	SELECT @IdProveedor, (CASE WHEN COUNT(IdContacto) = 0 THEN 0 ELSE @Puntos4_4 END), 19
	FROM dbo.S_Contacto_PA WHERE IdProveedor = @IdProveedor AND IdTipoContacto = 4 AND IsEliminado = 0
	
	INSERT INTO dbo.EI_ConceptosCompletados (IdProveedor, Completado, IdConceptoDetalle)
	SELECT @IdProveedor, (CASE WHEN IdGiroEmpresaria IS NULL THEN 0 ELSE @Puntos5_1 END), 20
	FROM dbo.PV_PerfilEmpresa WHERE IdProveedor = @IdProveedor
	
	INSERT INTO dbo.EI_ConceptosCompletados (IdProveedor, Completado, IdConceptoDetalle)
	SELECT @IdProveedor, (CASE WHEN AniosExperiencia IS NULL THEN 0 ELSE @Puntos5_2 END), 21
	FROM dbo.PV_PerfilEmpresa WHERE IdProveedor = @IdProveedor
	
	INSERT INTO dbo.EI_ConceptosCompletados (IdProveedor, Completado, IdConceptoDetalle)
	SELECT @IdProveedor, (CASE WHEN IdDocumentoCurriculum IS NULL THEN 0 ELSE @Puntos5_3 END), 22
	FROM dbo.PV_PerfilEmpresa WHERE IdProveedor = @IdProveedor
	
	INSERT INTO dbo.EI_ConceptosCompletados (IdProveedor, Completado, IdConceptoDetalle)
	SELECT @IdProveedor, (CASE WHEN IdDocumentoOrganigrama IS NULL THEN 0 ELSE @Puntos5_4 END), 23
	FROM dbo.PV_PerfilEmpresa WHERE IdProveedor = @IdProveedor
	
	INSERT INTO dbo.EI_ConceptosCompletados (IdProveedor, Completado, IdConceptoDetalle)
	SELECT @IdProveedor, (CASE WHEN COUNT(IdClientePrincipales) = 0 THEN 0 ELSE @Puntos5_5 END), 24
	FROM dbo.PV_ClientePrincipales WHERE IdProveedor = @IdProveedor AND Activo = 1
	
	INSERT INTO dbo.EI_ConceptosCompletados (IdProveedor, Completado, IdConceptoDetalle)
	SELECT @IdProveedor, (CASE WHEN COUNT(IdSocioComercial) = 0 THEN 0 ELSE @Puntos5_6 END), 25
	FROM dbo.PV_SocioComercial WHERE IdProveedor = @IdProveedor AND Activo = 1

	INSERT INTO dbo.EI_ConceptosCompletados (IdProveedor, Completado, IdConceptoDetalle)
	SELECT @IdProveedor, (CASE WHEN COUNT(IdMarca) = 0 THEN 0 ELSE @puntos5_7  END), 26
	FROM dbo.PV_ProveedorRepresentaMarca WHERE IdProveedor = @IdProveedor AND Activo = 1

	INSERT INTO dbo.EI_ConceptosCompletados (IdProveedor, Completado, IdConceptoDetalle)
	SELECT @IdProveedor, (CASE WHEN COUNT(da.IdDistribuidorAutorizado) = 0 THEN 0 ELSE @Puntos5_8 END), 27
	FROM dbo.PV_DistribuidorAutorizado da WHERE da.IdProveedor = @IdProveedor AND da.Activo = 1 
	
	INSERT INTO dbo.EI_ConceptosCompletados (IdProveedor, Completado, IdConceptoDetalle)
	SELECT @IdProveedor, (CASE WHEN COUNT(IdSistemaGestion) = 0 THEN 0 ELSE @Puntos6_1 END), 28
	FROM dbo.PV_SistemaGestion WHERE IdProveedor = @IdProveedor AND Documento IS NOT NULL AND Activo = 1 AND IdTipoDocSG = @IdSGISO14000
	
	INSERT INTO dbo.EI_ConceptosCompletados (IdProveedor, Completado, IdConceptoDetalle)
	SELECT @IdProveedor, (CASE WHEN COUNT(IdSistemaGestion) = 0 THEN 0 ELSE @Puntos6_2 END), 29
	FROM dbo.PV_SistemaGestion WHERE IdProveedor = @IdProveedor AND Documento IS NOT NULL AND Activo = 1 AND IdTipoDocSG = @IdSGISO18000
	
	INSERT INTO dbo.EI_ConceptosCompletados (IdProveedor, Completado, IdConceptoDetalle)
	SELECT @IdProveedor, (CASE WHEN COUNT(IdSistemaGestion) = 0 THEN 0 ELSE @Puntos6_3 END), 30
	FROM dbo.PV_SistemaGestion WHERE IdProveedor = @IdProveedor AND Documento IS NOT NULL AND Activo = 1 AND IdTipoDocSG = @IdSGESR
	
	INSERT INTO dbo.EI_ConceptosCompletados (IdProveedor, Completado, IdConceptoDetalle)
	SELECT @IdProveedor, (CASE WHEN COUNT(IdSistemaGestion) = 0 THEN 0 ELSE @Puntos6_4 END), 31
	FROM dbo.PV_SistemaGestion WHERE IdProveedor = @IdProveedor AND Documento IS NOT NULL AND Activo = 1 AND IdTipoDocSG = @IdSGCapacitacion
	
	INSERT INTO dbo.EI_ConceptosCompletados (IdProveedor, Completado, IdConceptoDetalle)
	SELECT @IdProveedor, (CASE WHEN COUNT(IdSistemaGestion) = 0 THEN 0 ELSE @Puntos6_5 END), 32
	FROM dbo.PV_SistemaGestion WHERE IdProveedor = @IdProveedor AND Documento IS NOT NULL AND Activo = 1 AND IdTipoDocSG = @IdSGOtra
	
	INSERT INTO dbo.EI_ConceptosCompletados (IdProveedor, Completado, IdConceptoDetalle)
	SELECT @IdProveedor, (CASE WHEN COUNT(IdSistemaGestion) = 0 THEN 0 ELSE @Puntos6_6 END), 33
	FROM dbo.PV_SistemaGestion WHERE IdProveedor = @IdProveedor AND Documento IS NOT NULL AND Activo = 1 AND IdTipoDocSG = @IdSGISO9000
	
	INSERT INTO dbo.EI_ConceptosCompletados (IdProveedor, Completado, IdConceptoDetalle)
	SELECT @IdProveedor, (CASE WHEN COUNT(IdSistemaGestion) = 0 THEN 0 ELSE @Puntos6_7 END), 34
	FROM dbo.PV_SistemaGestion WHERE IdProveedor = @IdProveedor AND Documento IS NOT NULL AND Activo = 1 AND IdTipoDocSG = @IdSGIndLimpia

	INSERT INTO dbo.EI_ConceptosCompletados (IdProveedor, Completado, IdConceptoDetalle)
	SELECT @IdProveedor, (CASE WHEN IdClasificacionEmpresa IS NULL THEN 0 ELSE @Puntos7_1 END), 35
	FROM dbo.PV_ClasificacionEmpresaProveedor WHERE IdProveedor = @IdProveedor
	
	INSERT INTO dbo.EI_ConceptosCompletados (IdProveedor, Completado, IdConceptoDetalle)
	select @IdProveedor, (CASE WHEN CapitalContable IS NULL THEN 0 ELSE @Puntos8_1 END), 36
	from dbo.S_Proveedor WHERE IdProveedor = @IdProveedor

	INSERT INTO dbo.EI_ConceptosCompletados (IdProveedor, Completado, IdConceptoDetalle)
	SELECT @IdProveedor, (CASE WHEN COUNT(IdEdoCuenta) = 0 THEN 0 ELSE @Puntos8_2 END), 37
	FROM dbo.CF_EdoCuentaDocumentos WHERE IdProveedor = @IdProveedor AND ISNULL(isEliminado,0)=0
		
	INSERT INTO dbo.EI_ConceptosCompletados (IdProveedor, Completado, IdConceptoDetalle)
	SELECT @IdProveedor, (CASE WHEN COUNT(IdDeclaracionFiscal) = 0 THEN 0 ELSE @Puntos8_3 END), 38
	FROM dbo.CF_DeclaracionFiscal WHERE IdProveedor = @IdProveedor
	
	INSERT INTO dbo.EI_ConceptosCompletados (IdProveedor, Completado, IdConceptoDetalle)
	SELECT @IdProveedor, (CASE WHEN COUNT(IdCartaOponionSat) = 0 THEN 0 ELSE @puntos8_4 END), 39
	FROM dbo.CF_CartaOpinionSAT WHERE IdProveedor = @IdProveedor AND Eliminado = 0 AND Carta IS NOT NULL
	
	INSERT INTO dbo.EI_ConceptosCompletados (IdProveedor, Completado, IdConceptoDetalle)
	SELECT @IdProveedor, (CASE WHEN COUNT(DatoBancarioID) = 0 THEN 0 ELSE @Puntos9_1 END), 40
	FROM dbo.PV_CuentaBancaria WHERE IdProveedor = @IdProveedor AND IsEliminado = 0
	
	INSERT INTO dbo.EI_ConceptosCompletados (IdProveedor, Completado, IdConceptoDetalle)
	SELECT @IdProveedor, (CASE WHEN COUNT(cp.IdCondicionPago) = 0 THEN 0 ELSE @Puntos10_1 END), 41
	FROM dbo.PV_CondicionesPago AS cp
		INNER JOIN dbo.PV_ContratistaSubContratista AS cc ON cc.IdRelacion = cp.IdContratistaSubContratista AND cc.IsActivo = 1
	WHERE cc.IdContratista = @IdProveedor
	
	INSERT INTO dbo.EI_ConceptosCompletados (IdProveedor, Completado, IdConceptoDetalle)
	SELECT @IdProveedor, (CASE WHEN COUNT(IdDocumento) = 0 THEN 0 ELSE @Puntos11_1 END), 42
	FROM dbo.S_Documento_S3 WHERE IdProveedor = @IdProveedor AND Identificador IS NOT NULL AND IdTipoDocumento = 1
	
	INSERT INTO dbo.EI_ConceptosCompletados (IdProveedor, Completado, IdConceptoDetalle)
	SELECT @IdProveedor, (CASE WHEN COUNT(IdDocumento) = 0 THEN 0 ELSE @Puntos11_2 END), 43
	FROM dbo.S_Documento_S3 WHERE IdProveedor = @IdProveedor AND Identificador IS NOT NULL AND IdTipoDocumento = 2
	
	INSERT INTO dbo.EI_ConceptosCompletados (IdProveedor, Completado, IdConceptoDetalle)
	SELECT @IdProveedor, (CASE WHEN COUNT(IdDocumento) = 0 THEN 0 ELSE @Puntos11_3 END), 44
	FROM dbo.S_Documento_S3 WHERE IdProveedor = @IdProveedor AND Identificador IS NOT NULL AND IdTipoDocumento = 3

	INSERT INTO dbo.EI_ConceptosCompletados (IdProveedor, Completado, IdConceptoDetalle)
	SELECT @IdProveedor, (CASE WHEN COUNT(IdDocumento) = 0 THEN 0 ELSE @Puntos11_4 END), 45
	FROM dbo.S_Documento_S3 WHERE IdProveedor = @IdProveedor AND Identificador IS NOT NULL AND IdTipoDocumento = 4

	INSERT INTO dbo.EI_ConceptosCompletados (IdProveedor, Completado, IdConceptoDetalle)
	SELECT @IdProveedor, (CASE WHEN COUNT(IdDocumento) = 0 THEN 0 ELSE @Puntos11_5 END), 46
	FROM dbo.S_Documento_S3 WHERE IdProveedor = @IdProveedor AND Identificador IS NOT NULL AND IdTipoDocumento IN (5, 6)
	
	INSERT INTO dbo.EI_ConceptosCompletados (IdProveedor, Completado, IdConceptoDetalle)
	SELECT @IdProveedor, (CASE WHEN COUNT(IdDocumento) = 0 THEN 0 ELSE @Puntos11_6 END), 47
	FROM dbo.S_Documento_S3 WHERE IdProveedor = @IdProveedor AND Identificador IS NOT NULL AND IdTipoDocumento = 7

	INSERT INTO dbo.EI_ConceptosCompletados (IdProveedor, Completado, IdConceptoDetalle)
	SELECT @IdProveedor, (CASE WHEN COUNT(IdDocumento) = 0 THEN 0 ELSE @Puntos11_7 END), 48
	FROM dbo.S_Documento_S3 WHERE IdProveedor = @IdProveedor AND Identificador IS NOT NULL AND IdTipoDocumento = 8

	INSERT INTO dbo.EI_ConceptosCompletados (IdProveedor, Completado, IdConceptoDetalle)
	SELECT @IdProveedor, (CASE WHEN COUNT(IdDocumento) = 0 THEN 0 ELSE @Puntos11_8 END), 49
	FROM dbo.S_Documento_S3 WHERE IdProveedor = @IdProveedor AND Identificador IS NOT NULL AND IdTipoDocumento = 9

	INSERT INTO dbo.EI_ConceptosCompletados (IdProveedor, Completado, IdConceptoDetalle)
	SELECT @IdProveedor, (CASE WHEN COUNT(IdDocumento) = 0 THEN 0 ELSE @Puntos11_9 END), 50
	FROM dbo.S_Documento_S3 WHERE IdProveedor = @IdProveedor AND Identificador IS NOT NULL AND IdTipoDocumento = 10

	INSERT INTO dbo.EI_ConceptosCompletados (IdProveedor, Completado, IdConceptoDetalle)
	SELECT @IdProveedor, (CASE WHEN COUNT(IdDocumento) = 0 THEN 0 ELSE @Puntos11_10 END), 51
	FROM dbo.S_Documento_S3 WHERE IdProveedor = @IdProveedor AND Identificador IS NOT NULL AND IdTipoDocumento = 13
	
	INSERT INTO dbo.EI_ConceptosCompletados (IdProveedor, Completado, IdConceptoDetalle)
	SELECT @IdProveedor, (CASE WHEN COUNT(IdReferenciaComercial) = 0 THEN 0 ELSE @Puntos12_1 END), 52
	FROM dbo.PV_ReferenciasComerciales WHERE Proveedor = @IdProveedor AND ReferenciaActiva = 1
	
	INSERT INTO dbo.EI_ConceptosCompletados (IdProveedor, Completado, IdConceptoDetalle)
	SELECT @IdProveedor, (CASE WHEN COUNT(IdMaterial) = 0 THEN 0 ELSE @Puntos13_1 END), 53
	FROM dbo.MM_Material WHERE IdProveedor = @IdProveedor
	
	INSERT INTO dbo.EI_ConceptosCompletados (IdProveedor, Completado, IdConceptoDetalle)
	SELECT @IdProveedor, (CASE WHEN COUNT(IdRelacion) = 0 THEN 0 ELSE @Puntos13_2 END), 54
	FROM PV_ContratistaSubContratista WHERE IdContratista = @IdProveedor AND IsActivo = 1
	
	INSERT INTO dbo.EI_ConceptosCompletados (IdProveedor, Completado, IdConceptoDetalle)
	SELECT @IdProveedor, (CASE WHEN COUNT(IdRelacion) = 0 THEN 0 ELSE @Puntos13_3 END), 55
	from PV_ContratistaSubContratista where IdSubContratista = @IdProveedor AND IsActivo = 1

	--Calculo del porcentaje
	DECLARE @TotalConceptos FLOAT,
			@ConceptosCapturados FLOAT,
			@Porcentaje FLOAT,
			@Existente INT

	--Obtengo el numero de conceptos que aplican a personas morales o fisicas
	IF(@TipoRegimen = 2)
	BEGIN
		SET @TotalConceptos = (SELECT SUM(Puntos) FROM dbo.EI_ConceptosDetalle WHERE SoloMoral = 0)
	END	
	ELSE
    BEGIN
		SET @TotalConceptos = (SELECT SUM(Puntos) FROM dbo.EI_ConceptosDetalle)
	end

	--Obtengo el total de conceptos capturados por el proveedor
	IF(@TipoRegimen = 2)
	BEGIN 
		SET @ConceptosCapturados = (SELECT SUM(cc.Completado) 
										FROM dbo.EI_ConceptosCompletados  cc
										INNER JOIN	dbo.EI_ConceptosDetalle cd ON cd.IdConceptoDetalle = cc.IdConceptoDetalle
										WHERE cc.IdProveedor = @IdProveedor AND cc.Completado > 0 AND cd.SoloMoral = 0)
	END
    ELSE
	BEGIN
		SET @ConceptosCapturados = (SELECT SUM(Completado) FROM dbo.EI_ConceptosCompletados WHERE IdProveedor = @IdProveedor AND Completado > 0)
	END
    
	--Obtengo el procentaje
	SET @Porcentaje = @ConceptosCapturados / @TotalConceptos

	SET @Existente = (SELECT COUNT(IdResultadoEG) FROM dbo.EI_Resultado WHERE IdProveedor = @IdProveedor)
	IF(@Existente > 0)
	BEGIN
		UPDATE dbo.EI_Resultado
		SET Resultado = @Porcentaje
		WHERE IdProveedor = @IdProveedor
	END
    ELSE
    BEGIN
		INSERT INTO dbo.EI_Resultado
		(
		    IdProveedor,
		    Resultado
		)
		VALUES
		(   @IdProveedor,  -- IdProveedor - int
		    @Porcentaje -- Resultado - float
		)
	END

	SELECT ROUND(@Porcentaje, 2)
END


