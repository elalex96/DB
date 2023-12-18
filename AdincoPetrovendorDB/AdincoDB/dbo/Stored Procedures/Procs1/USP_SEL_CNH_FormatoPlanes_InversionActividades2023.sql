IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'USP_SEL_CNH_FormatoPlanes_InversionActividades2023'
)
    DROP PROCEDURE USP_SEL_CNH_FormatoPlanes_InversionActividades2023;
GO
CREATE PROCEDURE [dbo].[USP_SEL_CNH_FormatoPlanes_InversionActividades2023]
@IdContrato          INT,   
@IdUsuario           INT,   
@Mes                 DATE,   
@IdProgramaActividad INT  
AS  
     BEGIN  
         SET NOCOUNT ON; 
	SELECT
    CO_ProgramaActividad.NombrePrograma AS PlanPrograma,
    CASE
        WHEN CO_Contrato.IdTipoContrato = 1
            THEN CO_TipoServicio.NombreTipoServicio
        ELSE
            CO_ActividadPetroleraCNH.DescripcionActividadPetrolera
    END                                 AS ActividadPetrolera,
    CASE
        WHEN CO_Contrato.IdTipoContrato = 1
            THEN CO_ActividadCIEP.NombreActividad
        ELSE
            CO_SubactividadPetrolera.SubactividadPetrolera
    END                                 AS SubActividadPetrolera,
    CASE
        WHEN CO_Presupuesto.CIEP = 1
            THEN CO_Rubro.NombreRubro
        ELSE
            CO_TareaPetrolera.TareaPetrolera
    END                                 AS Tarea,
	'Servicio' AS Descripcion
FROM
    CO_ProgramaActividad	(NOLOCK)
    JOIN
        CO_Presupuesto (NOLOCK)
            ON CO_ProgramaActividad.IdProgramaActividad = CO_Presupuesto.IdProgramaActividad
               AND CO_ProgramaActividad.IdProgramaActividad = @IdProgramaActividad
    JOIN
        CO_AnioContractual (NOLOCK)
            ON CO_AnioContractual.IdAnioContractual = CO_Presupuesto.IdAnioContractual
			AND CO_AnioContractual.IdContrato = @IdContrato
    JOIN
        CO_Contrato (NOLOCK)
            ON CO_Contrato.IdContrato = CO_AnioContractual.IdContrato
    JOIN
        CO_LineaPresupuestoMes (NOLOCK)
            ON CO_Presupuesto.IdPresupuesto = CO_LineaPresupuestoMes.IdPresupuesto
	JOIN 
		dbo.CO_Servicio  (NOLOCK)
		ON CO_LineaPresupuestoMes.IdServicio	=	CO_Servicio.IdServicio
    LEFT JOIN
        CO_TipoServicio (NOLOCK)
            ON CO_LineaPresupuestoMes.IdTipoServicio = CO_TipoServicio.IdTipoServicio
    LEFT JOIN
        dbo.CO_ActividadPetroleraCNH (NOLOCK)
            ON  dbo.CO_LineaPresupuestoMes.IdActividadPetrolera	=	CO_ActividadPetroleraCNH.IdActividadPetrolera
    LEFT JOIN
        CO_ActividadCIEP (NOLOCK)
            ON CO_LineaPresupuestoMes.IdActividad = CO_ActividadCIEP.IdActividad
               AND CO_LineaPresupuestoMes.IdActividad = CO_ActividadCIEP.IdActividad
    LEFT JOIN
        dbo.CO_SubactividadPetrolera (NOLOCK)
            ON  dbo.CO_LineaPresupuestoMes.IdSubactividadPetrolera	=	CO_SubactividadPetrolera.IdSubactividadPetrolera
    LEFT JOIN
        CO_Rubro (NOLOCK)
            ON CO_LineaPresupuestoMes.IdRubro = CO_Rubro.IdRubro
    LEFT JOIN
        dbo.CO_TareaPetrolera (NOLOCK)
            ON CO_LineaPresupuestoMes.IdTareaPetrolera = CO_TareaPetrolera.IdTareaPetrolera
WHERE
    CO_ProgramaActividad.IdProgramaActividad = @IdProgramaActividad
	AND CO_AnioContractual.IdContrato = @IdContrato
	AND CO_Servicio.NombreServicio NOT LIKE '%No elegibles%'  
GROUP BY
    CO_ProgramaActividad.NombrePrograma,
    CASE
        WHEN CO_Contrato.IdTipoContrato = 1
            THEN CO_TipoServicio.NombreTipoServicio
        ELSE
            CO_ActividadPetroleraCNH.DescripcionActividadPetrolera
    END,
    CASE
        WHEN CO_Contrato.IdTipoContrato = 1
            THEN CO_ActividadCIEP.NombreActividad
        ELSE
            CO_SubactividadPetrolera.SubactividadPetrolera
    END,
    CASE
        WHEN CO_Presupuesto.CIEP = 1
            THEN CO_Rubro.NombreRubro
        ELSE
            CO_TareaPetrolera.TareaPetrolera
    END
	ORDER BY 
	CO_ProgramaActividad.NombrePrograma,
    CASE
        WHEN CO_Contrato.IdTipoContrato = 1
            THEN CO_TipoServicio.NombreTipoServicio
        ELSE
            CO_ActividadPetroleraCNH.DescripcionActividadPetrolera
    END,
    CASE
        WHEN CO_Contrato.IdTipoContrato = 1
            THEN CO_ActividadCIEP.NombreActividad
        ELSE
            CO_SubactividadPetrolera.SubactividadPetrolera
    END,
    CASE
        WHEN CO_Presupuesto.CIEP = 1
            THEN CO_Rubro.NombreRubro
        ELSE
            CO_TareaPetrolera.TareaPetrolera
    END
END