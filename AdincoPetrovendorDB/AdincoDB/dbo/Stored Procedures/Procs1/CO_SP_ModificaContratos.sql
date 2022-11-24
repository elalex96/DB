CREATE PROCEDURE [dbo].[CO_SP_ModificaContratos]
	@IdContrato INT,
	@NumeroContrato VARCHAR(300),
	@DescripcionContrato VARCHAR(500),
	@IdContratista INT,
	@IdAreaContractual INT,
	@Activo bit,
	@IDRegFiducidiario VARCHAR(300),
	@Duracion INT,
	@FechaFirma DATE,
	@InicioVigencia DATE ,
	@FinVigencia DATE,
	@IdTipoContrato INT,
	@ValorRegaliaAdicional FLOAT,
	@IncrementoProgramaMinimo FLOAT, 
	@CreadoPor INT,
	@UsaProcura BIT,
	@PorcentajeRecuperacion FLOAT,
	@GasNoAsociado bit,
	@IdUbicacionGeografica int,
	@MesPresentacionCGI date,
	@IdRonda INT,
	@IsPC int,
	@IsConsorcio bit,
	@ParticipacionEstado varchar(500),
	@FechaArranqueEntregables date,
	@ContratoFicticio bit
AS
    BEGIN

	UPDATE	[CO_Contrato] 
		SET	[NumeroContrato] = @NumeroContrato, 
			[DescripcionContrato] = @DescripcionContrato, 
			[IdContratista] = @IdContratista, 
			[IdAreaContractual] = @IdAreaContractual, 
			[Activo] = @Activo, 
			[IDRegFiducidiario] = @IDRegFiducidiario, 
			[Duracion] = @Duracion, 
			[FechaFirma] = @FechaFirma, 
			[InicioVigencia] = @InicioVigencia, 
			[FinVigencia] = @FinVigencia,
			[IdTipoContrato] = @IdTipoContrato, 
			[ValorRegaliaAdicional] = @ValorRegaliaAdicional, 
			[IncrementoProgramaMinimo] =@IncrementoProgramaMinimo, 
			[ModificadoPor] = @CreadoPor,
			[UsaProcura] = @UsaProcura,
			[PorcentajeRecuperacion] = @PorcentajeRecuperacion,
			[GasNoAsociado] = @GasNoAsociado,
			[IdUbicacionGeografica] = @IdUbicacionGeografica,
			[MesPresentacionCGI] = @MesPresentacionCGI,
			[IdRonda] = @IdRonda,
			[IsPC] = @IsPC,
			[IsConsorcio] = @IsConsorcio,
			[ParticipacionEstado] = @ParticipacionEstado,
			[FechaArranqueEntregables] = @FechaArranqueEntregables,
			[ContratoFicticio]= @ContratoFicticio,
			[ModificadoEl]=GETDATE()
	WHERE IdContrato = @IdContrato;

END;




/*    <asp:SqlDataSource ID="SqlDataSourceContratos" runat="server" ConnectionString="<%$ ConnectionStrings:Adinco_ConnectionString %>"
        DeleteCommand="DELETE FROM [CO_Contrato] WHERE [IdContrato] = @IdContrato"
       InsertCommand="INSERT INTO [CO_Contrato] ([NumeroContrato], [DescripcionContrato], [IdContratista], [IdAreaContractual], [Activo], [IDRegFiducidiario], [Duracion], [FechaFirma], [InicioVigencia], [FinVigencia], [IdTipoContrato], [ValorRegaliaAdicional], [IncrementoProgramaMinimo], [CreadoPor],[UsaProcura]) VALUES (@NumeroContrato, @DescripcionContrato, @IdContratista, @IdAreaContractual, @Activo, @IDRegFiducidiario, @Duracion, @FechaFirma, @InicioVigencia, @FinVigencia, @IdTipoContrato, @ValorRegaliaAdicional, @IncrementoProgramaMinimo, @CreadoPor,@UsaProcura)"
        SelectCommand="[sp_CO_ObtenerContratosPDF]" SelectCommandType="StoredProcedure"
        UpdateCommand="UPDATE [CO_Contrato] SET [NumeroContrato] = @NumeroContrato, [DescripcionContrato] = @DescripcionContrato, [IdContratista] = @IdContratista, [IdAreaContractual] = @IdAreaContractual, [Activo] = @Activo, [IDRegFiducidiario] = @IDRegFiducidiario, [Duracion] = @Duracion, [FechaFirma] = @FechaFirma, [InicioVigencia] = @InicioVigencia, [FinVigencia] = @FinVigencia, [IdTipoContrato] = @IdTipoContrato, [ValorRegaliaAdicional] = @ValorRegaliaAdicional, [IncrementoProgramaMinimo] = @IncrementoProgramaMinimo, [CreadoPor] = @CreadoPor,[UsaProcura]=@UsaProcura WHERE [IdContrato] = @IdContrato">
        <DeleteParameters>
            <asp:Parameter Name="IdContrato" Type="Int32" />
        </DeleteParameters>
        <InsertParameters>
            <asp:Parameter Name="NumeroContrato" Type="String" />
            <asp:Parameter Name="DescripcionContrato" Type="String" />
            <asp:Parameter Name="IdContratista" Type="Int32" />
            <asp:Parameter Name="IdAreaContractual" Type="Int32" />
            <asp:Parameter Name="Activo" Type="Boolean" />
            <asp:Parameter Name="UsaProcura" Type="Boolean" />
            <asp:Parameter Name="IDRegFiducidiario" Type="String" />
            <asp:Parameter Name="Duracion" Type="Int32" />
            <asp:Parameter DbType="Date" Name="FechaFirma" />
            <asp:Parameter DbType="Date" Name="InicioVigencia" />
            <asp:Parameter DbType="Date" Name="FinVigencia" />
            <asp:Parameter Name="IdTipoContrato" Type="Int32" />
            <asp:Parameter Name="ValorRegaliaAdicional" Type="Double" />
            <asp:Parameter Name="IncrementoProgramaMinimo" Type="Double" />
            <asp:Parameter Name="CreadoPor" Type="Int32" />
        </InsertParameters>
        <UpdateParameters>
            <asp:Parameter Name="NumeroContrato" Type="String" />
            <asp:Parameter Name="DescripcionContrato" Type="String" />
            <asp:Parameter Name="IdContratista" Type="Int32" />
            <asp:Parameter Name="IdAreaContractual" Type="Int32" />
            <asp:Parameter Name="Activo" Type="Boolean" />
            <asp:Parameter Name="UsaProcura" Type="Boolean" />
            <asp:Parameter Name="IDRegFiducidiario" Type="String" />
            <asp:Parameter Name="Duracion" Type="Int32" />
            <asp:Parameter DbType="Date" Name="FechaFirma" />
            <asp:Parameter DbType="Date" Name="InicioVigencia" />
            <asp:Parameter DbType="Date" Name="FinVigencia" />
            <asp:Parameter Name="IdTipoContrato" Type="Int32" />
            <asp:Parameter Name="ValorRegaliaAdicional" Type="Double" />
            <asp:Parameter Name="IncrementoProgramaMinimo" Type="Double" />
            <asp:Parameter Name="CreadoPor" Type="Int32" />
            <asp:Parameter Name="IdContrato" Type="Int32" />
        </UpdateParameters>
    </asp:SqlDataSource>*/