USE [Adinco]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_Migracion_EntregablesInstancias'
)
    DROP PROCEDURE SP_Migracion_EntregablesInstancias;
GO 
/****** Object:  StoredProcedure [dbo].[TA_SP_ConsultaCorreos]    Script Date: 16/02/2022 10:47:50 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SP_Migracion_EntregablesInstancias]-- 3,'ADINCO-1086'
@ContratoId DATETIME,
@EntregableIdentificador VARCHAR(MAX)
AS
BEGIN
	  --> REFERENCIA EN_EntregablesHistorial
     --  exec SP_Migracion_EntregablesInstancias 3,'ADINCO-1094'

     DECLARE @EntregableId INT= (SELECT IdEntregable FROM EN_Entregable WHERE Consecutivo=@EntregableIdentificador)

	 
	
	    SELECT I.idInstanciaEntregable AS ProgramacionId,  
			   I.FechaCalculadaEntregaReg AS FechaCalculadaEntregaReg,
			   I.FechaRealEntregaRegulador AS FechaRealEntrega,
			   Es.NombreEstado AS NombreEstado,		
			   I.CreadoPor,
			   I.CreadoEn as CreadoEl,
			   I.Activo,
			   ISNULL(I.BitContieneAcuse, 0) AS ContieneAcuse,
			   A.EstadoID,  
			   E.IdEntregable,	
			   ISNULL(P.NombreProceso+' - '+IPF .Descripcion,'')	AS  NombreProgramacionProcesos
        FROM 
		EN_InstanciasEntregable	I  
        JOIN 
			EN_ContratoEntregable	CE  
			ON	I.IdContratoEntregable	=	CE.IdContratoEntregable  
			AND	CE.IdContrato	=	@ContratoId
			AND	CE.Activo	=	1
			AND	I.Activo	=	1  
		JOIN
			EN_Actividad	A
			ON	I.ActividadID	=	A.ActividadID
			AND	A.EstadoID	=	10003	--Aprobado Internamente    
		JOIN 
			EN_Estado Es  
			ON A.EstadoID = Es.EstadoID  
		JOIN 
			dbo.EN_Entregable	e  
			ON	CE.IdEntregable	=	e.IdEntregable  
			AND E.IdEntregable	= @EntregableId
			AND	E.IsActivo	=	1
			AND E.BitJOA	=	0
        LEFT JOIN 
			dbo.EN_MarcoLegal ml  
			ON	e.IdMarcoLegal	=	ml.IdMarcoLegal  
		LEFT	JOIN
					EN_InstanciasEntregables_InstanciaActividad IEIA
					ON I.idInstanciaEntregable	=	IEIA.idInstanciaEntregable
		LEFT	JOIN
				EN_InstanciasActividades	IA
				ON	IEIA.idInstanciaActividad	=	IA.idInstanciaActividad
		LEFT JOIN 
				EN_InstanciasProcesosFecha	IPF
				ON	IA.IdInstanciasProcesos	=	IPF.IdInstanciasProcesos
		LEFT JOIN 
					EN_Procesos	P
					ON	IPF.IdProceso	=	P.IdProceso
        WHERE	CE.IdContrato	=	@ContratoId 
              AND  
              (  
                  ml.Activo = 1  
                  OR e.BitInterno = 1  
              )  
        ORDER BY FechasLimiteAprobacion ASC; 
			

END;



