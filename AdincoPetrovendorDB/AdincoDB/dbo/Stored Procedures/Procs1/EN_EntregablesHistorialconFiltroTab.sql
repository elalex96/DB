USE Adinco
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'EN_EntregablesHistorialconFiltroTab'
)
    DROP PROCEDURE EN_EntregablesHistorialconFiltroTab;
GO
/****** Object:  StoredProcedure [dbo].[EN_EntregablesHistorialconFiltroTab]    Script Date: 22/09/2022 12:48:22 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:	DANIEL AC
-- Create date: <04/11/2021>
-- Description:	Filtro para cargar informacion en /2/Entregables/entregablesadministradorcontrato.aspx
-- =============================================
CREATE PROCEDURE [dbo].[EN_EntregablesHistorialconFiltroTab]
	-- Add the parameters for the stored procedure here
	@idUsuario INT,  
    @idContrato INT,  
    @BitPantallaArea INT=-1,  
    @BitProcesos INT=-1,  
    @BitTodos INT=-1,
	@BitFinalizados INT=-1,
	@ActivosSHELL BIT = NULL,
	@DataSource NVARCHAR(MAX) = '',
	@TabActive NVARCHAR(MAX) = ''
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	/*
	@TabActive-->Indica el tab que se esta mostrando o que esta activo
	@DataSource -->Indica el nombre del SqlDataSource
	*/
	SET NOCOUNT ON;
	

	IF @TabActive='tbEntregableA' AND @DataSource='SqlHistorial' 
		BEGIN

		EXECUTE [dbo].[EN_EntregablesHistorial] 
		   @idUsuario
		  ,@idContrato
		  ,@BitPantallaArea
		  ,@BitProcesos
		  ,@BitTodos
		  ,@BitFinalizados
		  ,@ActivosSHELL
	END
    
    IF @TabActive='tbEntregableFuturos' AND @DataSource='sdEntregablesFuturos' 
		BEGIN		
	
		EXECUTE [dbo].[EN_EntregablesHistorialMasTresAnios] 
	    @idUsuario
	   ,@idContrato
	   ,@BitPantallaArea
	END
		
	IF @TabActive='tbEntregableDesactivados' AND @DataSource='SqlDesactivados' 
		BEGIN
		
		EXECUTE [dbo].[EN_EntregablesDesactivados] 
		   @idUsuario
		  ,@idContrato
		  ,@BitPantallaArea		 

	END

	IF @TabActive='tbEntregableProcesos' AND @DataSource='sdProcesos' 
		BEGIN
	
		EXECUTE [dbo].[EN_EntregablesHistorial] 
		   @idUsuario
		  ,@idContrato
		  ,@BitPantallaArea
		  ,@BitProcesos
		  ,@BitTodos
		  ,@BitFinalizados
		  ,@ActivosSHELL
	END
	
	IF @TabActive='tbEntregableTodos' AND @DataSource='sdTodos' 
		BEGIN
	
		EXECUTE [dbo].[EN_EntregablesHistorial] 
		   @idUsuario
		  ,@idContrato
		  ,@BitPantallaArea
		  ,@BitProcesos
		  ,@BitTodos
		  ,@BitFinalizados
		  ,@ActivosSHELL
	END

	IF @TabActive='tbEntregableFinalizados' AND @DataSource='sdFinalizados' 
		BEGIN
	
		EXECUTE [dbo].[EN_EntregablesHistorial] 
		   @idUsuario
		  ,@idContrato
		  ,@BitPantallaArea
		  ,@BitProcesos
		  ,@BitTodos
		  ,@BitFinalizados
		  ,@ActivosSHELL
	END

END