-- =============================================
-- Author: Pedro Acuña
-- Create date: 30/04/2018
-- Description: saber por la aplicacion 
--app = 1 es la aprobacion de reyna consta de dos aprobacion una de revision y otra de aprobacion y
--app=2  que son las aprobaciones en gral solo consta de una aprobacion
-- =============================================

CREATE PROCEDURE [dbo].[SP_MA_WSRevisarEstatusGralxApp] 
--
@IdDocumento INT, 
@IdApp       INT
AS
     BEGIN
         DECLARE @LineaTiempo INT, @CantidadAprobados INT;
         SELECT @LineaTiempo = linea.IdLineaTiempo
         FROM Adinco.dbo.MA_LineaTiempo linea
              INNER JOIN Adinco.dbo.MA_Operacion operacion ON operacion.IdDocumento = linea.IdDocumento
                                                              AND operacion.IdLineaTiempo = linea.IdLineaTiempo
         WHERE linea.IdDocumento = @IdDocumento
               AND operacion.IdApp = @IdApp
         ORDER BY linea.IdLineaTiempo DESC;
         IF(@LineaTiempo IS NOT NULL)
             BEGIN
                 IF(@IdApp = 1
                    OR @IdApp = 2)
                     BEGIN
                         SELECT @CantidadAprobados = COUNT(*)
                         FROM Adinco.dbo.MA_Operacion
                         WHERE IdDocumento = @IdDocumento
                               AND IdLineaTiempo = @LineaTiempo
                               AND IdEstatusOperacion = 2;
                         IF(@CantidadAprobados = 2) --Deben de ser 2 ya que es la revision y la aprobacion de la misma linea de tiempo 
                             BEGIN
                                 SELECT 2, 
                                        'Estatus Aprobado';
                             END;
                     END;
                     ELSE
                 IF(@IdApp = 3)
                     BEGIN
                         IF EXISTS
                         (
                             SELECT 1
                             FROM Adinco.dbo.MA_Operacion
                             WHERE IdDocumento = @IdDocumento
                                   AND IdLineaTiempo = @LineaTiempo
                                   AND IdEstatusOperacion = 2
                         )
                             SELECT 2, 
                                    'Estatus Aprobado';
                     END;
             END;
             ELSE
         SELECT-1, 
               'No encontrado';
     END;