-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <20/08/2019>
-- Description:	<consultar las PO DEA>
-- =============================================
CREATE PROCEDURE [dbo].[DEA_SP_ConsultaPO] --420
	-- Add the parameters for the stored procedure here}
	@IdProveedor INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	--PO'S QUE NO TIENE NINGUNA RELACIÓN CON ALGUN PEDIDO PR 
    -- Insert statements for procedure here
	SELECT
			 POS.ID_PO,
			 POS.CreadoEl,
			 POS.IdDocumento,
			 POS.IdAdjuntoPO,
			 Contrato = c.NumeroContrato
	FROM dbo.DEA_AdjuntoPO AS POS
		LEFT JOIN dbo.DEA_Relacion_PR_PO AS DEAR 
		ON DEAR.PO = POS.ID_PO --> POR EL MOMENTO LA PO PUEDE REPETIRSE 
		AND DEAR.IdAdjuntoPO=POS.IdAdjuntoPO --> EL ADJUNTO ES UN PARAMETRO UNICO
		LEFT JOIN dbo.MM_Pedido P ON P.IdPedido= DEAR.IdPedido AND ISNULL(P.IdEstatusEliminado,0)=1
		left JOIN	Adinco.dbo.CO_Contrato	AS	C 	ON	P.IdContrato	=	C.IdContrato 
	WHERE DEAR.ID_R_PR_PO IS NULL
		  AND ISNULL(DEAR.Activo,0) = 0
	GROUP BY POS.ID_PO,
             POS.CreadoEl,
             POS.IdDocumento,
             POS.IdAdjuntoPO,
			 c.NumeroContrato,
			 c.IdContrato
	ORDER BY POS.ID_PO DESC
	
	
END
