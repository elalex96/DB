USE [Petrovendor]
GO

/****** Object:  Table [dbo].[WDEA_SAP_TerminosCondiciones]    Script Date: 27/07/2022 02:09:52 p. m. ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[WDEA_SAP_TerminosCondiciones](
	[IdCatTerminosCondiciones] [int] IDENTITY(1000,1) NOT NULL,
	[Clabe] [varchar](30) NULL,
	[DiasCredito] [int] NULL,
 CONSTRAINT [PK_WDEA_SAP_TerminosCondiciones] PRIMARY KEY CLUSTERED 
(
	[IdCatTerminosCondiciones] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO


