IF OBJECT_ID('[dbo].[sp_OT_ConsultaSolicitudPrograma]', 'P') IS NOT NULL
    DROP PROCEDURE [dbo].sp_OT_ConsultaSolicitudPrograma
GO
-- sp_OT_ConsultaSolicitudPrograma 24
CREATE Proc [dbo].[sp_OT_ConsultaSolicitudPrograma] @pIdOTSolicitud int
As
CREATE TABLE #tmpMeses
(
    mes INT,
    nombreMes VARCHAR(30),
    anio INT,
    anioMes VARCHAR(6)
);

DECLARE @anioIni INT,
        @anioFin INT;

SELECT @anioIni = MIN(YEAR(FechaProgramaInicio)),
       @anioFin = MAX(YEAR(FechaProgramaFin))
FROM OT_SolicitudMaterial (NOLOCK)
WHERE IdOTSolicitud = @pIdOTSolicitud;


INSERT INTO #tmpMeses
(
    mes,
    nombreMes,
    anio,
    anioMes
)
SELECT 
	MES,
	NombreMes,
	ANIO,
	CAST(Anio As Varchar(4)) + RIGHT('0' + CAST(Mes AS Varchar(2)), 2)
FROM
	AP_CALENDARIO (NOLOCK)
WHERE ANIO BETWEEN @anioIni AND @anioFin
GROUP BY 
	MES, NombreMes, Anio,
	CAST(Anio AS VARCHAR(4)) + RIGHT('0' + CAST(Mes AS VARCHAR(2)), 2)



select IDPrograma = cast(sm.IdOTSolicitudMaterial AS VARCHAR) + '-' + cast(meses.Anio as varchar) + '-'
                    + cast(meses.Mes AS VARCHAR),
       IdOTSolicitudMaterial = sm.IdOTSolicitudMaterial,
       FechaProgramaInicio = sm.FechaProgramaInicio,
       FechaProgramaFin = sm.FechaProgramaFin,
       Mes = meses.Mes,
       NombreMes = meses.NombreMes,
       Anio = meses.Anio,
       CantidadMes = isnull(sp.Cantidad, 0),
       Descripcion = isnull(sc.Concepto, sc.IdMaestro) + cast(sc.Descripcion as varchar(150)),
       IdOTSolicitudPrograma = isnull(sp.IdOTSolicitudPrograma, 0),
       CantidadOT = sm.Cantidad
from OT_SolicitudMaterial sm (NOLOCK)
    inner join SC_Materiales sc (NOLOCK)
        on sm.IdSCMaterial = sc.IdSCMaterial
    inner join #tmpMeses meses (NOLOCK)
        on meses.aniomes >= CONVERT(INT, CONVERT(varchar(6), sm.FechaProgramaInicio, 112))
           and meses.aniomes <= CONVERT(INT, CONVERT(VARCHAR(6), sm.FechaProgramaFin, 112))
    LEFT JOIN OT_SolicitudPrograma sp (NOLOCK)
        on sm.IdOTSolicitudMaterial = sp.IdOTSolicitudMaterial
           and meses.anio = sp.anio
           and meses.mes = sp.mes
where IdOTSolicitud = @pIdOTSolicitud
group by sm.IdOTSolicitudMaterial,
         sm.FechaProgramaInicio,
         sm.FechaProgramaFin,
         meses.nombremes,
         meses.mes,
         meses.anio,
         sp.Cantidad,
         sc.Descripcion,
         sp.IdOTSolicitudPrograma,
         sm.Cantidad,
         sc.Concepto,
         sc.IdMaestro
order by sm.IdOTSolicitudMaterial,
         sm.FechaProgramaInicio,
         sm.FechaProgramaFin,
         meses.anio,
         meses.mes




