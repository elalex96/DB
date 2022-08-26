USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'ME_ConsultarMatrizPorPedido'
)
DROP PROCEDURE ME_ConsultarMatrizPorPedido;
GO
/****** Object:  StoredProcedure [dbo].[ME_ConsultarMatrizPorPedido]    Script Date: 26/08/2022 02:55:51 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:	Daniel AC
-- Create date: <25/08/2022>
-- Description:	Optimización de sp
-- =============================================
CREATE procedure [dbo].[ME_ConsultarMatrizPorPedido] 
	@IdPedido INT
AS
BEGIN
	SELECT m.IdDocMatriz, m.NombreDoc, m.IdOperacion
	FROM dbo.TA_DocMatrizOperacion m  (NOLOCK)
	JOIN dbo.MM_PeticionOferta p   (NOLOCK)
	ON m.IdOperacion = p.IdSolicitudPedido
	WHERE p.IdPeticionOferta = @IdPedido
END