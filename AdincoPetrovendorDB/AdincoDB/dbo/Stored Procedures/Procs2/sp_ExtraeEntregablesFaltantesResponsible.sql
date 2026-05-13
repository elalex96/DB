CREATE PROCEDURE [dbo].[sp_ExtraeEntregablesFaltantesResponsible]--10146,10082
    @IdContrato INT,
    @idUsuario INT
AS
BEGIN--285718
    -- =============================================
    -- Author:  Reyna Olvera
    -- Create date: 2018-11-08
    -- Description: 
    -- 20190510 BAAC    Se modifica consulta de las fechas proximas para no considerar el id de la instancia
    -- =============================================
    SET	NOCOUNT	ON;
    DECLARE	@Count	INT	=	0;

    SELECT @Count =	COUNT(1)
	--SELECT *
    FROM EntregablesShellFacts ESF
	JOIN AP_Usuario U
		ON	ESF.Usuario	=	U.Nombre
	WHERE
		ESF.Status = 'En Elaboración'
		AND U.UsuarioID = @idUsuario

    SELECT IE.idInstanciaEntregable	AS	idInstanciaEntregable,
           CE.IdEntregable	AS	IdEntregable,
           CE.IdContratoEntregable	AS	IdContratoEntregable,
           DocumentoEntregable,
           ISNULL(R.Regulador,'')	AS	Regulador,
           ISNULL( ESF.MarcoLegal,'')	AS	MarcoLegal,
           IE.FechasLimiteElaboracion,
           IE.FechaCalculadaEntregaReg	AS	FechaEntregaRegulador,
           IE.FechasLimiteAprobacion,
           ESF.Status	AS	Estatus,
           ISNULL(F.FrecuenciaEntregable,'')	AS	FrecuenciaEntregable,
           ISNULL(ET.Etapa,'')	AS	Etapa,
           ISNULL(EN.idRegulador,'')	AS	idRegulador,
          @Count AS countI,
           EN.Consecutivo,
		   ISNULL(EN.Articulo,'') AS Articulo,
			ESF.FocalPoint AS FocalPoint,
			ESF.AccountableCompliance	AS AccountableCompliance,
			ESF.Accountable	AS Accountable,
			ESF.Usuario AS Responsible,
			A.EstadoID,
			CASE
				WHEN A.EstadoID = 10003 THEN '#49525e' -- NEGRO 1
				WHEN DATEDIFF(DAY,IE.FechaCalculadaEntregaReg,GETDATE()) > 0 AND A.EstadoID <> 10003 THEN '#49525e'	-- NEGRO 1
				WHEN (CONVERT(FLOAT,DATEDIFF(DAY,GETDATE(),IE.FechaCalculadaEntregaReg))/CONVERT(FLOAT,DATEDIFF(DAY, IE.FechaInicioElaboracion,IE.FechaCalculadaEntregaReg))) BETWEEN 0 AND 0.4 THEN '#e03531' -- ROJO 2
				WHEN (CONVERT(FLOAT,DATEDIFF(DAY,GETDATE(),IE.FechaCalculadaEntregaReg))/CONVERT(FLOAT,DATEDIFF(DAY, IE.FechaInicioElaboracion,IE.FechaCalculadaEntregaReg))) BETWEEN 0.41 AND 0.69 THEN '#e39802' -- AMARILLO 3
				WHEN (CONVERT(FLOAT,DATEDIFF(DAY,GETDATE(),IE.FechaCalculadaEntregaReg))/CONVERT(FLOAT,DATEDIFF(DAY, IE.FechaInicioElaboracion,IE.FechaCalculadaEntregaReg))) > 0.69 THEN '#51b364' -- VERDE 4
	END		AS EstatusParaColor
			--SELECT *
    	FROM EntregablesShellFacts ESF (NOLOCK)
	JOIN
		EN_InstanciasEntregable	IE	(NOLOCK)
		ON	ESF.ID	=	IE.idInstanciaEntregable
    JOIN	
		EN_ContratoEntregable	CE (NOLOCK)
		ON	IE.IdContratoEntregable	=	CE.IdContratoEntregable
		AND CE.IdContrato =	@IdContrato
    JOIN	
		dbo.EN_Actividad A	(NOLOCK)
		ON	IE.ActividadID	=	A.ActividadID
    JOIN	
		EN_Entregable EN (NOLOCK)
		ON CE.IdEntregable	=	EN.IdEntregable
		AND EN.BITJOA = 0
	JOIN
		AP_Usuario U	(NOLOCK)
		ON	ESF.Usuario	=	U.Nombre
    LEFT	JOIN	
		dbo.CO_Regulador R (NOLOCK)
		ON EN.IdRegulador	=	R.IdRegulador
    LEFT	JOIN	
		dbo.EN_FrecuenciaEntregable F (NOLOCK)
		ON EN.IdFrecuenciaEntregable	=	F.IdFrecuenciaEntregable
    LEFT	JOIN	
		EN_Etapa ET (NOLOCK)
		ON EN.IdEtapa	=	ET.IdEtapa
  --  LEFT	JOIN	
		--dbo.EN_MarcoLegal M 
		--ON EN.IdMarcoLegal	=	M.IdMarcoLegal
	WHERE
		ESF.Status = 'En Elaboración'
		AND U.UsuarioID = @idUsuario
	ORDER BY EstadoID desc, FechaCalculadaEntregaReg asc
    
    END;