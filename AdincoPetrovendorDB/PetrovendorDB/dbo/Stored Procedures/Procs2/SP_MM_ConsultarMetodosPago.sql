USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_MM_ConsultarMetodosPago'
)
DROP PROCEDURE SP_MM_ConsultarMetodosPago;
GO
/****** Object:  StoredProcedure [dbo].[SP_MM_ConsultarMetodosPago]    Script Date: 25/08/2022 02:29:49 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:  Daniel AC
-- Create date: 16-10-2019
-- Description:Consultar métodos de pago
-- =============================================
-- =============================================
-- Author:	Daniel AC
-- Create date: <25/08/2022>
-- Description:	Optimización de sp
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_ConsultarMetodosPago] 
	-- Add the parameters for the stored procedure here
	@IdProveedor INT

AS
	BEGIN
		-- SET NOCOUNT ON added to prevent extra result sets  from
		-- interfering with SELECT statements.
		SET NOCOUNT ON ;
		
		SELECT IdCondicionPago, CondicionPago 
		FROM MM_CondicionPago (NOLOCK)
		WHERE Activo=1
	
	END
