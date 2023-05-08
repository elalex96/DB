-- =============================================
-- Author:		<Jose Roman>
-- Create date: <09-08-2018>
-- Description:	<Se consultan los proveedores en Solicitud oferta detalle mercadeo>
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 15/Jul/2019
-- Description:	se agrego la lista negra del sat
-- =============================================
-- Author:		Abel Rivera
-- Create date: 16/Jul/2019
-- Description:	Se agrega el campo para validar la lista negra al select

CREATE PROCEDURE [dbo].[SP_ConsultaProveedoresFiltro] @IdProveedor   INT,

                                                     /*---------------------Parametros contrato---------------------*/

                                                     @IdContrato    INT      = NULL, 
                                                     @IdUsuario     INT      = NULL, 
                                                     @FechaRegistro DATETIME = NULL

/*---------------------Parametros contrato---------------------*/

AS
    BEGIN
        SELECT P.IdProveedor,
               CASE
                   WHEN LN.RFC IS NULL
                   THEN CONCAT(P.RazonSocial, '  ', P.RegimenCapital)
                   ELSE CONCAT(P.RazonSocial, '  ', P.RegimenCapital, ' - DESABILITADO POR SAT - [Situación: ', LN.Situacion COLLATE Modern_Spanish_CI_AS, ']')
               END AS NombreProveedor, 
			   0 AS Estrellas,
			   /**Optimizacion**/
               --ISNULL(dbo.ObtenerEstrellasModificado(P.IdProveedor), 0) AS Estrellas, 
               P.RFC,
               CASE
                   WHEN LN.RFC IS NULL
                   THEN 0
                   ELSE 1
               END AS InBlackList
        FROM S_Proveedor AS P
             INNER JOIN S_UsuarioProveedor AS UP ON UP.IdProveedor = P.IdProveedor
             LEFT JOIN Adinco.dbo.ListaNegra AS LN ON LN.RFC COLLATE Modern_Spanish_CI_AS = P.RFC COLLATE Modern_Spanish_CI_AS
        WHERE P.Activo = 1
              AND P.IdProveedor <> @IdProveedor
              AND ISNULL(P.IsEliminado, 0) = 0
        GROUP BY P.IdProveedor, 
                 P.RazonSocial, 
                 P.RegimenCapital, 
                 P.RFC, 
                 LN.RFC, 
                 LN.Situacion
        ORDER BY NombreProveedor;
    END;