CREATE PROC [dbo].[EN_ObtenObtenPlantillaConfiguracion]
@ContratoId int
AS 
BEGIN 
	SELECT 
	0 AS idInstanciaEntregable,
	E.IdEntregable,
	E.Consecutivo,
	case 
	when E.IsActivo = 1 
	then 'SI' 
	when e.IsActivo = 0
	then 'NO'
	END as Activo,
	E.DocumentoEntregable,
	ISNULL(ML.MarcoLegal,'') AS MarcoLegal,
	ISNULL(f.FrecuenciaEntregable,'') AS FrecuenciaEntregable,
	'NO' AS 'ProgramarEntregable',
	A.NombreArea, 
	ISNULL(CE.DiasAlerta,0) AS DiasAlerta,
	ISNULL(CE.DiasElaboracion,0) AS DiasElaboracion,
	ISNULL(CE.DiasRevision,0) AS DiasRevision,
	ISNULL(CE.DiasAprobacion,0) AS DiasAprobacion, 
	ISNULL(convert(varchar, CE.FechaLimiteEntregaRegulador, 103) ,'') as FechaLimiteEntregaRegulador,
	case when U.IsGrupo = 1 
	then ''
	else 
	ISNULL(U.Usuario,'') end AS 'Elaborador'
	FROM EN_ContratoEntregable CE 	
	JOIN EN_Entregable E
		on CE.IdEntregable = E.IdEntregable
	LEFT JOIN EN_Area (NOLOCK) A
		ON CE.IdArea = A.idArea
		AND	A.Activo = 1
		AND A.idContrato = @ContratoId
	LEFT JOIN EN_FrecuenciaEntregable F
		on E.IdFrecuenciaEntregable = F.IdFrecuenciaEntregable
	LEFT JOIN EN_MarcoLegal ML 
		ON E.IdMarcoLegal = ML.IdMarcoLegal
	LEFT JOIN EN_Actividad ACT
		ON CE.IdContratoEntregable = ACT.IdContratoEntregable	
		AND ACT.EstadoID = 10000		
	LEFT JOIN AP_Usuario U 
		ON ACT.idUsuario = U.UsuarioID		
	WHERE 	 
	CE.Activo = 1	
	AND ACT.Activo = 1
	AND	CE.IdContrato = @ContratoId
	AND E.Consecutivo IS NOT NULL
end


