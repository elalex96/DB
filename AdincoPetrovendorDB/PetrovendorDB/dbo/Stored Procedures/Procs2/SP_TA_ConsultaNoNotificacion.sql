-- =============================================
-- Author:		Pedro Acuña
-- Create date: 07/03/2018
-- Description:	Obtener los usuarios que no quieren ser notificados por correo
-- =============================================
CREATE PROCEDURE [dbo].[SP_TA_ConsultaNoNotificacion] @IdProveedor INT,
    ------------------------
                                                     @IdUsuario   INT,
                                                     @IdContrato  INT,
                                                     @FchRegistro DATETIME
-----------------
AS
     BEGIN
         DECLARE @tablaAux TABLE
(Checkbox           BIT,
 IdCorreo           INT,
 DescripcionCliente NVARCHAR(MAX),
 Descripcion        NVARCHAR(MAX)
);
         INSERT INTO @tablaAux
(IdCorreo,
 DescripcionCliente,
 Descripcion
)
                SELECT correo.IdCorreo,
                       correo.DescripcionCliente,
                       correo.Descripcion
                FROM dbo.TA_Correo correo
                WHERE correo.IdServidor = 2 --Procura
                      AND correo.IdCorreo NOT IN(9, 11, 12, 14, 15, 18, 22, 27, 25, 35, 36, 38, 39, 40, 41, 43, 50, 51, 52, 54, 55, 56, 57, 58, 59, 66);
         UPDATE tb
           SET
               tb.Checkbox = CASE
                                 WHEN IdUsuario IS NULL
                                 THEN 0
                                 ELSE 1
                             END
         FROM @tablaAux tb
              INNER JOIN dbo.TA_NoNotificacion ON TA_NoNotificacion.IdCorreo = tb.IdCorreo
         WHERE IdProveedor = @IdProveedor
               AND IdUsuario = @IdUsuario
               AND IsEliminado = 0;

    --Retorno a la vista
         SELECT CASE
                    WHEN Checkbox IS NULL
                    THEN 1
                    ELSE 0
                END Checkbox,
                IdCorreo,
                DescripcionCliente,
                Descripcion
         FROM @tablaAux;
     END;