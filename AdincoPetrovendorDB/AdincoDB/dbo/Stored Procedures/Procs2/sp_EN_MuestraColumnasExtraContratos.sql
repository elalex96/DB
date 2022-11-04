USE [Adinco]
GO
/****** Object:  StoredProcedure [dbo].[sp_EN_MuestraColumnasExtraContratos]    Script Date: 02/11/2022 11:39:55 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[sp_EN_MuestraColumnasExtraContratos]--3,10061
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
		END AS	MostrarFechaRealEvidencia,
		CASE 
			WHEN CC.NombreContratista LIKE '%Shell%' AND C.IdContrato = 10151 --CONTRATO SEGUIMIENTO DE PLANES DE ACCION
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
		END AS MostrarSPA
    FROM
        dbo.CO_Contratista  CC (NOLOCK)
    JOIN
        dbo.CO_Contrato C  (NOLOCK)
        ON  CC.IdContratista    =   C.IdContratista
    WHERE
        C.IdContrato    = @idContrato

END