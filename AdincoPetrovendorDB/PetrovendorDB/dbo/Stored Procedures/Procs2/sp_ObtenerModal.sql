CREATE PROCEDURE [dbo].[sp_ObtenerModal] (@IdTopic INT)
AS
BEGIN
    SELECT topic.FechaHoraJunta,
           domicilio.Domicilio,
           topic.Comentario,

           CASE
               WHEN estatus.Estatus = -1 THEN
                   'Pendiente'
               WHEN estatus.Estatus = 1 THEN
                   'Confirmada'
               WHEN estatus.Estatus = 0 THEN
                   'Cancelada'
           END AS NombreEstatus,
		   estatus.Estatus,
		   topic.IdDomicilio,
		   estatus.IdTopic,
		   estatus.IdProveedor
    FROM dbo.JA_TopicAclaraciones topic
        INNER JOIN dbo.JA_LugarJunta domicilio
            ON domicilio.IdLugar = topic.IdDomicilio
        INNER JOIN dbo.JA_Estatus estatus
            ON estatus.IdTopic = topic.IdTopic
    WHERE topic.IdTopic = @IdTopic

END
