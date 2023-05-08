--=======================================
-- Modificador: Neri del Angel
-- Fecha: 13 de Septiembre del 2022
-- Detalle: Se ajusta orden de joins y en los ON de los joins
--=======================================
CREATE procedure [dbo].[p_OT_ConsultaDocumentosEstimacion]
    @pIdOt int,
    @pIdContrato int = 0,
    @pIdUsuario int = 0,
    @pFechaInicio DateTime = null,
    @pFechaFin DateTime = null
as
begin

    select AWS_Documentos.AWSDocumentoId,
           AWS_Documentos.Bucket,
           AWS_Documentos.Folder,
           AWS_Documentos.UUIDAmazon,
           AWS_Documentos.NombreArchivo,
           AWS_Documentos.meta,
           AWS_Documentos.CreadoEl,
           SemanaDel = null,
           SemanaAl = null
    from OT_ProgramaAdjunto (NOLOCK)
        inner join AWS_Documentos (NOLOCK)
            on OT_ProgramaAdjunto.AWSDocumentoId = AWS_Documentos.AWSDocumentoId
    where OT_ProgramaAdjunto.IdOTSolicitud = @pIdOt
    union
    select AWS_Documentos.AWSDocumentoId,
           AWS_Documentos.Bucket,
           AWS_Documentos.Folder,
           AWS_Documentos.UUIDAmazon,
           AWS_Documentos.NombreArchivo,
           AWS_Documentos.meta,
           AWS_Documentos.CreadoEl,
           SemanaDel = OT_ProgramaAdjuntoSemana.FechaInicioSemana,
           SemanaAl = OT_ProgramaAdjuntoSemana.FechaFinSemana
    from OT_ProgramaAdjuntoSemana (NOLOCK)
        inner join OT_SolicitudMaterial (NOLOCK)
            on OT_ProgramaAdjuntoSemana.IdOTSolicitudMaterial = OT_SolicitudMaterial.IdOTSolicitudMaterial
        inner join AWS_Documentos (NOLOCK)
            on OT_ProgramaAdjuntoSemana.AWSDocumentoId = AWS_Documentos.AWSDocumentoId
    where OT_SolicitudMaterial.IdOTSolicitud = @pIdOt
          and (
                  (@pFechaInicio
          between OT_ProgramaAdjuntoSemana.FechaInicioSemana and OT_ProgramaAdjuntoSemana.FechaFinSemana
                  )
                  OR (@pFechaFin
          between OT_ProgramaAdjuntoSemana.FechaInicioSemana and OT_ProgramaAdjuntoSemana.FechaFinSemana
                     )
                  OR (
                         @pFechaInicio <= OT_ProgramaAdjuntoSemana.FechaFinSemana
                         and @pFechaInicio <= OT_ProgramaAdjuntoSemana.FechaInicioSemana
                         AND @pFechaFin >= OT_ProgramaAdjuntoSemana.FechaFinSemana
                         and @pFechaFin >= OT_ProgramaAdjuntoSemana.FechaInicioSemana
                     )
              )
    order by SemanaDel desc,
             AWS_Documentos.CreadoEl desc
end