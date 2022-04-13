
USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_MM_ActualizarFirmaTareaPedido'
)
    DROP PROCEDURE SP_MM_ActualizarFirmaTareaPedido;
/****** Object:  StoredProcedure [dbo].[SP_MM_ConsultaIdTareaPorPedido]    Script Date: 12/04/2022 02:18:33 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author: Daniel AC
-- Create date: 12-04-2022
-- Description:	 Se actualiza información de la firma de la tarea 
-- =============================================
CREATE procedure [dbo].[SP_MM_ActualizarFirmaTareaPedido]
	@IdOperacion INT,
	@IdUsuario INT,	
    @NoSecuencia INT,
	@Firma NVARCHAR(MAX)
AS
BEGIN
	
	UPDATE TA_Tarea
	SET IdFirma=@Firma 
	WHERE IdOperacion=@IdOperacion
	AND NoSecuencia=@NoSecuencia
	AND IdAprobador=@IdUsuario
	AND ISNULL(Activo,0)=1 --> CTE DEBE ESTAR ACTIVA LA TAREA
END