USE [Petrovendor]
go
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'DEA_SP_ConsultaPO'
)
    DROP PROCEDURE DEA_SP_ConsultaPO;
	GO
/****** Object:  StoredProcedure [dbo].[DEA_SP_ConsultaPO]    Script Date: 31/05/2022 03:47:09 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      <Alexander Gomez>
-- Create date: <20/08/2019>
-- Description: <consultar las PO DEA>
-- =============================================
-- =============================================
-- Author:		Daniel AC
-- Create date: <31/05/2022>
-- Description:	<Se elimina relación de   DEAR.PO = POS.ID_PO  para evitar duplicados >
-- =============================================
CREATE PROCEDURE [dbo].[DEA_SP_ConsultaPO]
    -- Add the parameters for the stored procedure here}
    @IdProveedor INT
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;
    --PO'S QUE NO TIENE NINGUNA RELACIÓN CON ALGUN PEDIDO PR 
    -- Insert statements for procedure here
/**JIGG**
COMPROBACIÓN POR RESTA DE MESES ENTRE DOS AÑOS DIFERENTES 
declare @fecha datetime
 select @fecha = '20210101'
select  @fecha,  DATEADD(MONTH, -3, @fecha)
**/ 
    SELECT
             POS.ID_PO,
             POS.CreadoEl,
             POS.IdDocumento,
             POS.IdAdjuntoPO,
             Contrato = c.NumeroContrato
    FROM dbo.DEA_AdjuntoPO AS POS
        LEFT JOIN dbo.DEA_Relacion_PR_PO AS DEAR 
        ON POS.IdAdjuntoPO = DEAR.IdAdjuntoPO --> EL ADJUNTO ES UN PARAMETRO UNICO
        LEFT JOIN dbo.MM_Pedido P ON DEAR.IdPedido = P.IdPedido AND ISNULL(P.IdEstatusEliminado,0)=1
        left JOIN   Adinco.dbo.CO_Contrato  AS  C   ON  P.IdContrato    =   C.IdContrato 
    WHERE DEAR.ID_R_PR_PO IS NULL
          AND ISNULL(DEAR.Activo,0) = 0
          AND pos.CreadoEl > DATEADD(MONTH, -3, GETDATE())
    GROUP BY POS.ID_PO,
             POS.CreadoEl,
             POS.IdDocumento,
             POS.IdAdjuntoPO,
             c.NumeroContrato,
             c.IdContrato
    ORDER BY POS.CreadoEl DESC
    
    
END