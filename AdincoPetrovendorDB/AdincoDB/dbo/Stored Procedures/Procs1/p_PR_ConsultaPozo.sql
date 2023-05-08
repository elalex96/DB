CREATE PROC p_PR_ConsultaPozo
    @pIdPozo INT,
    @pIdContrato INT
AS
--SELECT * FROM dbo.CO_EstadoPozos
SELECT p.Id,
       p.Clave,
       p.Nombre,
       p.Descripcion,
       p.Estatus,
       p.LDD,
       p.Estacion,
       p.Campo,
       p.ProduccionNeta,
       p.Tanque,
       p.UltimoControl,
       p.SubEstado,
       p.TipoProduccion,
       p.ActividadIncremental,
       p.TipoSistema,
       p.PozoTipo,
       p.Modificado,
       p.ModificadoPor,
       p.ModificadoServer,
       p.Alta,
       p.Comentarios,
       p.AnioActividad,
       p.UltimoControlValido,
       p.ProduccionBruta,
       p.PorcentajeAgua,
       p.X,
       p.Y,
       p.PotencialOperativo,
       p.PotencialOptimo,
       p.OFM,
       p.RegionFiscal,
       p.TipoFluidoPetroleo,
       p.TipoFluidoGas,
       p.PuntoEntregaID,
       RequiereValidacion = CASE
                                WHEN pv.IdPozo IS NOT NULL THEN
                                    1
                                ELSE
                                    0
                            END,
       EP.Descripcion AS NombreEstado,
       T.Nombre AS NombreTanque,
       Ca.Nombre AS NombreCampo,
       PE.Nombre AS NombrePE,
       ES.Nombre AS NombreEstacion
FROM PR_Pozo p
    INNER JOIN CO_Contrato C
        ON C.idContrato = @pIdContrato
    INNER JOIN CO_PuntosdeEntregaContrato pec
        ON pec.idContrato = C.idContrato
           AND pec.PuntoEntregaID = p.PuntoEntregaID
    LEFT JOIN [PR_PozoCargaValidacion] pv
        ON pv.IdPozo = p.Id
           AND pv.ValidadoPor IS NULL
    LEFT JOIN dbo.CO_EstadoPozos EP
        ON p.Estatus = EP.idEstatus
    LEFT JOIN PR_Tanque T
        ON p.Tanque = T.Id
    LEFT JOIN dbo.PR_Campo Ca
        ON p.Campo = Ca.Id
    LEFT JOIN dbo.CO_PuntosdeEntrega PE
        ON p.PuntoEntregaID = PE.PuntoEntregaID
    LEFT JOIN dbo.PR_Estacion ES
        ON p.Estacion = ES.Id
WHERE @pIdPozo IN ( 0, p.Id )
ORDER BY (CASE
              WHEN pv.IdPozo IS NOT NULL THEN
                  1
              ELSE
                  0
          END
         ) DESC,
         p.Nombre;





