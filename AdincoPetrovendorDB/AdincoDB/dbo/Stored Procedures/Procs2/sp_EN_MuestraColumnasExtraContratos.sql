CREATE PROCEDURE [dbo].[sp_EN_MuestraColumnasExtraContratos]-- 3,10061
    @idContrato INT,
    @idUsuario  INT
AS
BEGIN
SET NOCOUNT ON

    SELECT   
		CASE 
			WHEN CC.NombreContratista LIKE '%Shell%' 
				THEN 1
			WHEN CC.NombreContratista LIKE '%Repsol%' 
				THEN 2
			WHEN CC.NombreContratista LIKE '%BP%' 
				THEN 2
			WHEN CC.NombreContratista LIKE '%MURPHY%' 
				THEN 2
			WHEN CC.NombreContratista LIKE '%Smart%' 
				THEN 1
			ELSE   0
		END AS Mostrar,

		CASE WHEN CC.NombreContratista LIKE '%Shell%' --Tab de todos en historial de entregables
				THEN 1
			WHEN CC.NombreContratista LIKE '%Repsol%' 
				THEN 1
			WHEN CC.NombreContratista LIKE '%BP%' 
				THEN 1
			ELSE   1
		END AS MostrarTab,
 
		0 AS MostrarNotificaciones,--Notificaciones de procesos, aún no liberado

		CASE 
			WHEN CC.NombreContratista LIKE '%Shell%' 
				THEN 1
			WHEN CC.NombreContratista LIKE '%Repsol%' 
				THEN 1
			WHEN CC.NombreContratista LIKE '%BP%' 
				THEN 1
			WHEN CC.NombreContratista LIKE '%Smart%' 
				THEN 1
			WHEN CC.NombreContratista LIKE '%ENI%' 
				THEN 1
			WHEN CC.NombreContratista LIKE '%MURPHY%' 
				THEN 1
			WHEN CC.NombreContratista LIKE '%Operadora Bloque%' 
				THEN 1
			ELSE   1
		END AS MostrarOpcionAcuse,
		CASE 
			WHEN CC.NombreContratista LIKE '%Dea%' 
				THEN 1
			WHEN CC.NombreContratista LIKE '%Murphy%' 
				THEN 1
			ELSE   0
		END AS	MostrarAnexo,
		CASE 
			WHEN CC.NombreContratista LIKE '%Dea%' 
				THEN 'Anexo3'
			ELSE   'Anexo3'
		END AS	NombreAnexo,
		CASE 
			WHEN CC.NombreContratista LIKE '%Shell%' 
				THEN 1
			ELSE   0
		END AS	MostrarComentario,
		CASE 
			WHEN CC.NombreContratista LIKE '%Shell%' 
				THEN 1
			ELSE   0
		END AS	MostrarFechaRealEvidencia
    FROM
        CO_Contratista  CC
    JOIN
        CO_Contrato C
        ON  CC.IdContratista    =   C.IdContratista
    WHERE
        C.IdContrato    =   @idContrato

END