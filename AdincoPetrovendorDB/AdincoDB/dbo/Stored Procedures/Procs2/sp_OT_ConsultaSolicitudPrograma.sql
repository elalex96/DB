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

;WITH Years
AS (SELECT @anioIni AS anio
    UNION ALL
    SELECT anio + 1
    FROM Years
    WHERE anio < @anioFin
   )
INSERT INTO #tmpMeses
(
    mes,
    nombreMes,
    anio,
    anioMes
)
SELECT m.mes,
       m.nombreMes,
       y.anio,
       CAST(y.anio AS VARCHAR(4)) + RIGHT('0' + CAST(m.mes AS VARCHAR(2)), 2) AS anioMes
FROM Years y
    CROSS JOIN
    (
        VALUES
            (1, 'Enero'),
            (2, 'Febrero'),
            (3, 'Marzo'),
            (4, 'Abril'),
            (5, 'Mayo'),
            (6, 'Junio'),
            (7, 'Julio'),
            (8, 'Agosto'),
            (9, 'Septiembre'),
            (10, 'Octubre'),
            (11, 'Noviembre'),
            (12, 'Diciembre')
    ) m (mes, nombreMes)
OPTION (MAXRECURSION 0);


select IDPrograma = cast(sm.IdOTSolicitudMaterial as varchar) + '-' + cast(meses.Anio as varchar) + '-'
                    + cast(meses.Mes as varchar),
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
        on meses.aniomes >= cast(cast((datepart(yy, sm.FechaProgramaInicio)) as varchar)
                                 + cast(case
                                            when datepart(mm, sm.FechaProgramaInicio) = 1 then
                                                '01'
                                            when datepart(mm, sm.FechaProgramaInicio) = 2 then
                                                '02'
                                            when datepart(mm, sm.FechaProgramaInicio) = 3 then
                                                '03'
                                            when datepart(mm, sm.FechaProgramaInicio) = 4 then
                                                '04'
                                            when datepart(mm, sm.FechaProgramaInicio) = 5 then
                                                '05'
                                            when datepart(mm, sm.FechaProgramaInicio) = 6 then
                                                '06'
                                            when datepart(mm, sm.FechaProgramaInicio) = 7 then
                                                '07'
                                            when datepart(mm, sm.FechaProgramaInicio) = 8 then
                                                '08'
                                            when datepart(mm, sm.FechaProgramaInicio) = 9 then
                                                '09'
                                            when datepart(mm, sm.FechaProgramaInicio) = 10 then
                                                '10'
                                            when datepart(mm, sm.FechaProgramaInicio) = 11 then
                                                '11'
                                            when datepart(mm, sm.FechaProgramaInicio) = 12 then
                                                '12'
                                        end as varchar) as int)
           and meses.aniomes <= cast(cast((datepart(yy, sm.FechaProgramaFin)) as varchar)
                                     + cast(case
                                                when datepart(mm, sm.FechaProgramaFin) = 1 then
                                                    '01'
                                                when datepart(mm, sm.FechaProgramaFin) = 2 then
                                                    '02'
                                                when datepart(mm, sm.FechaProgramaFin) = 3 then
                                                    '03'
                                                when datepart(mm, sm.FechaProgramaFin) = 4 then
                                                    '04'
                                                when datepart(mm, sm.FechaProgramaFin) = 5 then
                                                    '05'
                                                when datepart(mm, sm.FechaProgramaFin) = 6 then
                                                    '06'
                                                when datepart(mm, sm.FechaProgramaFin) = 7 then
                                                    '07'
                                                when datepart(mm, sm.FechaProgramaFin) = 8 then
                                                    '08'
                                                when datepart(mm, sm.FechaProgramaFin) = 9 then
                                                    '09'
                                                when datepart(mm, sm.FechaProgramaFin) = 10 then
                                                    '10'
                                                when datepart(mm, sm.FechaProgramaFin) = 11 then
                                                    '11'
                                                when datepart(mm, sm.FechaProgramaFin) = 12 then
                                                    '12'
                                            end as varchar) as int)
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




