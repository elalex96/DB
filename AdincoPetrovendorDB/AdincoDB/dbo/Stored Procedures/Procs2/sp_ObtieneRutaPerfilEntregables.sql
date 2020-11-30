CREATE PROCEDURE [dbo].[sp_ObtieneRutaPerfilEntregables]--3,10061,256582,'inst=MjU2NTgy','&Estat=MA==','&Usu=MTAwNjE=','&TO=Mw==','&ET=MQ=='
	@IdContrato INT,
	@IdUsuario INT,
	@IdInstancia INT,
	@InstanciaEncript VARCHAR(100),
	@EstatusEncript VARCHAR(100),
	@UsuarioEncript VARCHAR(100),
	@TipoOperacionEncript VARCHAR(100),
	@EsTableroEncript VARCHAR(100),
	@Recalculo    BIT = 0,
	@opcionBoton VARCHAR(100) = null
AS
BEGIN
	SET NOCOUNT ON;
-- =============================================
-- Author:		Reyna Olvera
-- Create date: 20200401
-- Description:	Llama las rutas, de acuerdo al perfil
-- =============================================
DECLARE @IsEntregableProceso INT	=	0, @IdInstanciaActividad INT	=	0, @IdProceso INT = 0, @IdInstanciaProceso	INT = 0, @ActConFechaReal int;

IF (@Recalculo = 1 )
BEGIN
 
	SELECT  @IsEntregableProceso = COUNT(1), 
			@IdInstanciaActividad	=	IA.idInstanciaActividad,
			@IdProceso =	IPF.IdProceso,
			@IdInstanciaProceso	=	IA.IdInstanciasProcesos
	FROM
	EN_InstanciasEntregable	 IE	(NOLOCK)
	JOIN	
		EN_ContratoEntregable	CE	(NOLOCK)
		ON IE.idInstanciaEntregable	=	@IdInstancia
		AND	IE.IdContratoEntregable	=	CE.IdContratoEntregable
		AND CE.IdContrato	=	@IdContrato
	JOIN
		EN_InstanciasEntregables_InstanciaActividad		IEIA	(NOLOCK)
		ON IE.idInstanciaEntregable	=	IEIA.idInstanciaEntregable
	JOIN
		EN_InstanciasActividades	IA	(NOLOCK)
		ON IEIA.idInstanciaActividad	=	IA.idInstanciaActividad
	JOIN
		EN_InstanciasProcesosFecha	IPF	(NOLOCK)
		ON IA.IdInstanciasProcesos	=	IPF.IdInstanciasProcesos
	GROUP BY IA.idInstanciaActividad,IPF.IdProceso,IA.IdInstanciasProcesos

	SELECT @ActConFechaReal = COUNT(1) FROM  EN_InstanciasActividades WHERE IdInstanciasProcesos = @IdInstanciaProceso AND FechaRealActividad IS NOT NULL;
	

	SELECT 
	CASE @IsEntregableProceso
	WHEN 1
		THEN
			CASE 
				WHEN @ActConFechaReal = 0
				THEN   
					   '../../2/Entregables/CalculoFechasProcesos.aspx?idProceso=' + ltrim(@IdProceso) 
				ELSE
					   '../../2/Entregables/RecalculoDetalleProcesos.aspx?idProceso=' + ltrim(@IdProceso)+'&idInstanciaProceso='+ ltrim(@IdInstanciaProceso)
			 END
	ELSE
		'../../2/Entregables/RespuestaEntregable.aspx?'+	@InstanciaEncript	+	@EstatusEncript	+	@UsuarioEncript	+	@TipoOperacionEncript	+'&Com='''
	END
		AS RutaPerfilEntregables 

 END
ELSE
BEGIN	
	SELECT 
	CASE
		WHEN
			P.IdContrato IN (10049,10050,10054,10055,10056,10057)
		THEN 
			'../../2/Entregables/subeHistorico.aspx?' + 'inst=' + LTRIM(@IdInstancia)
		WHEN 
			R.ROL LIKE '%ADMIN%' AND R.ROL NOT LIKE '%REPSOL%'AND @IdUsuario NOT IN ( 10765) --, 10654, 10769)
		THEN 
			'../../2/Entregables/RespuestaEntregable.aspx?'+	@InstanciaEncript	+	@EstatusEncript	+	@UsuarioEncript	+	@TipoOperacionEncript	+'&Com='''+	@EsTableroEncript
		WHEN 
			R.ROL LIKE '%Managment%'
		THEN 
			'../../2/Entregables/RespuestaEntregable.aspx?'+	@InstanciaEncript	+	@EstatusEncript	+	@UsuarioEncript	+	@TipoOperacionEncript	+'&Com='''+	@EsTableroEncript
		WHEN 
			R.ROL LIKE '%RESPONSABLE%'
		THEN 
			'../../2/Entregables/subeEntregables.aspx?' + 'inst=' + LTRIM(@IdInstancia)
		WHEN 
			R.ROL LIKE '%Elaborador%'
		THEN 
			'../../2/Entregables/subeEntregables.aspx?' + 'inst=' + LTRIM(@IdInstancia)
		WHEN
			R.ROL LIKE '%ADMIN%' AND R.ROL NOT LIKE '%REPSOL%' AND @IdUsuario IN ( 10765) --, 10654, 10769)
		THEN 
			'../../2/Entregables/subeHistorico.aspx?' + 'inst=' + LTRIM(@IdInstancia)
		WHEN
			R.ROL LIKE '%ADMIN%' AND R.ROL LIKE '%REPSOL%'
		THEN 
			'../../2/Entregables/subeHistorico.aspx?' + 'inst=' + LTRIM(@IdInstancia)
		WHEN
			R.ROL LIKE '%SASISOPA%' AND R.ROL LIKE '%REPSOL%'
		THEN 
			'../../2/Entregables/subeHistorico.aspx?' + 'inst=' + LTRIM(@IdInstancia)
		WHEN
			R.ROL LIKE '%CARGA%HISTOR%'
		THEN 
			'../../2/Entregables/subeHistorico.aspx?' + 'inst=' + LTRIM(@IdInstancia)
		ELSE
			'../../2/Entregables/HistorialArea.aspx'
	END AS RutaPerfilEntregables
	FROM
		AP_PerfilUsuario	PU
	JOIN
		AP_Perfil	P
		ON PU.PerfilID	=	P.IdPerfil
		AND PU.UsuarioID	=	@IdUsuario
		AND P.IdContrato	=	@IdContrato	
	JOIN 
		AP_Rol	R	
		ON P.IdRol	=	R.IdRol
END
END
