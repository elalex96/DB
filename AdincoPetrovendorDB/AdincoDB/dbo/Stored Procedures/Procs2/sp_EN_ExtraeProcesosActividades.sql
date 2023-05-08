-- =============================================
-- Author:		Reyna Olvera
-- Create date: 20181023
-- =============================================
CREATE PROCEDURE [dbo]. [sp_EN_ExtraeProcesosActividades]--3,10061
						-- [sp_EN_ExtraeProcesos]3,10061
	@idContrato INT,
	@idUsuario INT
AS
BEGIN

	SET NOCOUNT ON;

	SELECT
			p.IdProceso,
			CASE Isnull(clave,'')
				WHEN  ''
				THEN NombreProceso
				ELSE 
			clave +' '+NombreProceso
			END AS NombreProceso,
			Descripcion,
			idinstalacion,
			IsProcesoEvento,
			ISNULL(p.IsSerie,1) AS isSerie,
			isnull(clave,'') as Clave,
			P.CreadoEl,
			U.Nombre AS CreadoPor,
			COUNT(PA.idActividad) as CantidadActividades
	FROM
		EN_Procesos p
	JOIN 
		en_procesosContrato PC 
		ON PC.idProceso	=	p.IdProceso
	JOIN 
		AP_Usuario U
		ON P.CreadoPor	=	U.UsuarioID
	LEFT JOIN 
		EN_ProcesosActividades PA
		ON	P.IdProceso	=	PA.IdProceso
	LEFT JOIN 
		EN_Actividades	A
		ON PA.idActividad	=	A.IdActividad
	WHERE 
		PC.idContrato	=	@idContrato 
		AND idTipoProceso	=	10000
		AND p.Activo	=	1
		AND ISNULL(PA.Activo,1)	=	1
		AND ISNULL(A.Activo,1)	=	1
		AND (PA.Orden IS NULL
		OR PA.Orden >= 0)
	GROUP BY 
		p.IdProceso,
		CASE Isnull(clave,'')
			WHEN  ''
			THEN NombreProceso
			ELSE 
		clave +' '+NombreProceso
		END ,
		Descripcion,
		idinstalacion,
		IsProcesoEvento,
		p.IsSerie,
		clave,
		P.CreadoEl,
		U.Nombre
END






