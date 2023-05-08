-- =============================================
-- Author:		Reyna Olvera
-- Create date: 2019/02/14
-- Description:Verifica el flujo de elaboradores
-- =============================================

CREATE PROCEDURE [dbo].[sp_EN_VisualizaFlujo] --16841,10061,3
    @IdContratoEntregable INT,
    @idUsuario INT,
    @idContrato INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT e.NombreEstado,
           U.Nombre,
           A1.idUsuario,
           e.EstadoId,
           tf.CreadoEN,
           CASE e.EstadoID
                WHEN 10000 THEN '<div class="container">
	<div class="line text-center">
		<h5>Elaborador: ' + U.Nombre + '</h5>
		<div class="lines"></div>
	</div>'
                WHEN 10001 THEN '<div class="line text-center">
		<h5>Revisor: ' + U.Nombre + '</h5>
		<div class="linesa"></div>
	</div>'
                WHEN 10002 THEN '<div class="line text-center">
	    <h5>Aprobador Encargado de subir acuse:' + U.Nombre + '</h5>
		<div class="linesb"></div>
	</div>
</div>'    END AS html
      FROM EN_Transicion tf
      JOIN dbo.EN_Actividad A1
        ON tf.ActividadInicialID   = A1.ActividadID
       AND tf.IdContratoEntregable = A1.IdContratoEntregable
      JOIN dbo.EN_Actividad A2
        ON tf.SiguienteActividadID = A2.ActividadID
       AND tf.IdContratoEntregable = A1.IdContratoEntregable
      JOIN en_estado e
        ON A1.estadoID             = e.estadoID
      JOIN en_estado e1
        ON A1.estadoID             = e1.estadoID
      JOIN AP_Usuario U
        ON U.UsuarioID             = A1.IDUsuario
     WHERE e.estadoId              <> 10003
       AND tf.IdContratoEntregable = @IdContratoEntregable
     GROUP BY e.NombreEstado,
              A1.idUsuario,
              U.Nombre,
              e.EstadoId,
              tf.CreadoEN
     ORDER BY e.EstadoId,
              tf.CreadoEN ASC;
END;

