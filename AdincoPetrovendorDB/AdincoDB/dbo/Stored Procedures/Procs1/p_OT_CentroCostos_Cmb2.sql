IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'p_OT_CentroCostos_Cmb2'
)
    DROP PROCEDURE p_OT_CentroCostos_Cmb2
GO

CREATE PROCEDURE [dbo].[p_OT_CentroCostos_Cmb2]
    @pIdContrato INT,
    @pUsuarioId  INT
AS
BEGIN
    SELECT
        cc.IdCentroCosto,
        cc.CentroCosto,
        cc.IdProveedor
    FROM
        petrovendor..CC_CentroCosto cc (NOLOCK)
    INNER JOIN
        Adinco..CO_Contrato c (NOLOCK)
        ON c.IdContrato = @pIdContrato
    INNER JOIN
        Adinco..CO_Contratista cont (NOLOCK)
        ON cont.IdContratista = c.IdContratista
    INNER JOIN
        petrovendor..s_proveedor prov (NOLOCK)
        ON prov.RFC COLLATE SQL_Latin1_General_CP1_CI_AS = cont.RFC COLLATE SQL_Latin1_General_CP1_CI_AS  
        AND prov.IdProveedor = cc.IdProveedor
    WHERE
        cc.IsActivo = 1
    GROUP BY
        cc.IdCentroCosto,
        cc.CentroCosto,
        cc.IdProveedor
    ORDER BY
        cc.CentroCosto
END


