USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'DEA_SP_GuardarRelacion_PR_PO'
)
    DROP PROCEDURE DEA_SP_GuardarRelacion_PR_PO;
	GO
/****** Object:  StoredProcedure [dbo].[DEA_SP_GuardarRelacion_PR_PO]    Script Date: 30/05/2022 05:55:50 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <20/08/2019>
-- Description:	<Guardar Relacion de PR y PO>
-- =============================================
-- =============================================
-- Author:		<Daniel AC>
-- Create date: <31/05/2022>
-- Description:	<Se cambio NVARCHAR(50) A NVARCHAR(MAX) DE PARAMETRO @ID_PO>
-- =============================================
CREATE PROCEDURE [dbo].[DEA_SP_GuardarRelacion_PR_PO] 
	-- Add the parameters for the stored procedure here
	@ID_PO NVARCHAR(MAX),
	@IdPedido INT,
	@IdUsuario INT, 
	@IdProveedor INT = 0,
	@IdAdjuntoPO INT =0 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @ExisteRelacionPO INT , @ExisteRelacionPedidoPR INT 

	--VALIDAR SI LA PO NO ESTA RELACIONADA
	SELECT @ExisteRelacionPO =COUNT(ID_R_PR_PO)
	FROM DEA_Relacion_PR_PO  RP
	INNER JOIN dbo.MM_Pedido P ON RP.IdPedido = P.IdPedido
	WHERE RP.IdAdjuntoPO=@IdAdjuntoPO 
	AND ISNULL(P.IdEstatusEliminado,0)=0  --> SI EL PEDIDO ESTA ELIMINADO SI SE PUEDE VOLVER A RELACIONAR LA PO 
 
	--VALIDAR QUE EL PEDIDO-PR NO ESTE RELACIONADO 
	SELECT @ExisteRelacionPedidoPR =COUNT(ID_R_PR_PO)
	FROM DEA_Relacion_PR_PO  RP
	INNER JOIN dbo.MM_Pedido P ON RP.IdPedido = P.IdPedido
	WHERE RP.IdPedido=@IdPedido 
	AND ISNULL(P.IdEstatusEliminado,0)=0  --> SI EL PEDIDO ESTA ELIMINADO SI SE PUEDE VOLVER A RELACIONAR LA PO 
  
	--SI LA PO Y EL PEDIDO PR NO ESTAN RELACIONADOS AGREGAR NUEVA RELACIÓN
	IF ISNULL(@ExisteRelacionPO,0)=0  AND ISNULL(@ExisteRelacionPedidoPR,0)=0
	BEGIN 

    -- Insert statements for procedure here
	INSERT INTO dbo.DEA_Relacion_PR_PO
	(
	    PO,
		IdPedido,
	    FechaAltaRelacion,
	    CreadoPor,
	    Activo,
		IdCreadoProveedor,
		IdAdjuntoPO
	)
	VALUES
	(   @ID_PO,       -- PR - nvarchar(MAX)
	    @IdPedido,       -- PO - INT
	    GETDATE(), -- FechaAltaRelacion - datetime
	    @IdUsuario,         -- CreadoPor - int
	    1,      -- Activo - bit
		@IdProveedor,
		@IdAdjuntoPO
	   )

	SELECT SCOPE_IDENTITY() AS ID_R_PR_PO
	END 
	ELSE 
	BEGIN 
		SELECT -1,@ExisteRelacionPO, @ExisteRelacionPedidoPR, 'Existe alguna relación'
	END 

END
