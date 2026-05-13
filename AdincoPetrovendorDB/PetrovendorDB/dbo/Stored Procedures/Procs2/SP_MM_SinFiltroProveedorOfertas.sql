-- =============================================
-- Author:		Pedro Acuña
-- Create date: 26-03-18
-- Description:	Consultar sin FILTRO DE PROVEEDORES solo se descarta los proveedores que ya han sido seleccionados
-- Author:		Abel Rivera
-- Create date: 16/Jul/2019
-- Description:	Se agrega el campo para validar la lista negra al select
-- =============================================
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_SinFiltroProveedorOfertas] @IdProveedorActual INT, 
                                                        @IdSolicitudPedido INT
AS
    BEGIN
	/**Optimizacion*/
        SET NOCOUNT ON;
        DECLARE @tablaSubcontratistas TABLE
        (Fila        INT, 
         IdProveedor INT
        );
        INSERT INTO @tablaSubcontratistas
        (Fila, 
         IdProveedor
        )
               SELECT ROW_NUMBER() OVER(
                      ORDER BY IdSubcontratista), 
                      IdSubcontratista
               FROM dbo.MM_PeticionOferta
               WHERE IdSolicitudPedido = @IdSolicitudPedido
                     AND Activo = 1
                     AND IdTipoProceso = 2; --Mercadeo

        SELECT P.IdProveedor,
               CASE
                   WHEN LN.RFC IS NULL
                   THEN CONCAT(P.RazonSocial, '  ', P.RegimenCapital)
                   ELSE CONCAT(P.RazonSocial, '  ', P.RegimenCapital, ' - DESABILITADO POR SAT - [Situación: ', LN.Situacion COLLATE Modern_Spanish_CI_AS, ']')
               END AS NombreProveedor, 
               dbo.ObtenerEstrellasModificado(p.IdProveedor) AS Estrellas,
               CASE
                   WHEN LN.RFC IS NULL
                   THEN 0
                   ELSE 1
               END AS InBlackList
        FROM S_Proveedor AS P
             INNER JOIN S_UsuarioProveedor AS UP ON UP.IdProveedor = P.IdProveedor
           --  LEFT JOIN PV_ClasificacionEmpresaProveedor AS CE ON CE.IdProveedor = P.IdProveedor
           --  LEFT JOIN PV_ClasificacionPyMES AS CP ON CP.IdClasificacion = CE.IdClasificacionEmpresa
           --  LEFT JOIN PV_PerfilEmpresa AS PE ON PE.IdProveedor = P.IdProveedor
             LEFT JOIN adinco.dbo.ListaNegra LN ON LN.RFC COLLATE Modern_Spanish_CI_AS = P.RFC COLLATE Modern_Spanish_CI_AS
        WHERE P.Activo = 1
              AND P.IdProveedor <> @IdProveedorActual
             -- AND ISNULL(PE.AniosExperiencia, 0) >= 0
             -- AND ISNULL(P.CapitalContable, 0) >= 0
              AND P.IdProveedor NOT IN
        (
            SELECT IdProveedor
            FROM @tablaSubcontratistas
        )
        GROUP BY P.IdProveedor, 
                 P.RazonSocial, 
                 P.RegimenCapital
				 , 
                 LN.Situacion, 
                 LN.RFC
        ORDER BY NombreProveedor;
    END;